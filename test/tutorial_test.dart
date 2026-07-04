import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startenergy/core/app_assets.dart';
import 'package:startenergy/features/cutscene/cutscene_frame.dart';
import 'package:startenergy/features/tutorial/tutorial_prompt.dart';
import 'package:startenergy/features/tutorial/tutorial_screen.dart';
import 'package:startenergy/features/tutorial/tutorial_script.dart';

import 'test_app.dart';

void main() {
  const intro = [
    CutsceneFrame(
      characterSprite: AppAssets.linkSprite,
      spriteColumns: 3,
      text: 'Oi',
    ),
    CutsceneFrame(
      characterSprite: AppAssets.linkSprite,
      spriteColumns: 3,
      spriteIndex: 2,
      text: 'Vamos',
    ),
  ];

  Future<void> pumpTutorial(
    WidgetTester tester, {
    List<CutsceneFrame> introFrames = intro,
    VoidCallback? onFinished,
  }) {
    return tester.pumpWidget(
      testApp(
        TutorialScreen(
          introFrames: introFrames,
          random: Random(7),
          onFinished: onFinished ?? () {},
        ),
      ),
    );
  }

  Finder card(Particle p) => find.byKey(ValueKey(p));

  Finder quizOpacity() => find.byType(AnimatedOpacity);

  testWidgets('balões introdutórios avançam no toque e liberam as cartas', (
    tester,
  ) async {
    await pumpTutorial(tester);
    await tester.pumpAndSettle(); // conclui a digitação da 1ª fala

    expect(find.text('Oi'), findsOneWidget);
    expect(
      tester.widget<AnimatedOpacity>(quizOpacity()).opacity,
      0,
      reason: 'painel e cartas ficam ocultos durante a intro',
    );

    await tester.tap(find.byType(TutorialScreen));
    await tester.pumpAndSettle();
    expect(find.text('Vamos'), findsOneWidget);

    await tester.tap(find.byType(TutorialScreen));
    await tester.pumpAndSettle(); // cartas caem + fala de jogo digita
    expect(find.text(tutorialPlayFrame.text), findsOneWidget);
    expect(tester.widget<AnimatedOpacity>(quizOpacity()).opacity, 1);
    for (final p in Particle.values) {
      expect(card(p), findsOneWidget);
    }
  });

  testWidgets('tocar as cartas na ordem das dicas conclui o tutorial', (
    tester,
  ) async {
    var finished = false;
    await pumpTutorial(
      tester,
      introFrames: const [], // pula direto para as cartas
      onFinished: () => finished = true,
    );
    await tester.pumpAndSettle();

    // Ordem correta = ordem dos prompts (elétron, próton, nêutron).
    await tester.tap(card(tutorialPrompts[0].answer));
    await tester.pump();
    expect(find.text('1'), findsOneWidget); // selo de sequência na carta

    await tester.tap(card(tutorialPrompts[1].answer));
    await tester.tap(card(tutorialPrompts[2].answer));
    await tester.pumpAndSettle();

    expect(find.text(tutorialDoneFrame.text), findsOneWidget);
    expect(finished, isFalse);

    await tester.tap(find.byType(TutorialScreen));
    await tester.pump();
    expect(finished, isTrue);
  });

  testWidgets('carta errada não conta ponto na sequência', (tester) async {
    await pumpTutorial(tester, introFrames: const []);
    await tester.pumpAndSettle();

    // A 1ª dica pede elétron; tocar outra carta não deve marcar.
    await tester.tap(card(tutorialPrompts[1].answer));
    await tester.pumpAndSettle(); // animação de "balançar"
    expect(find.text('1'), findsNothing);

    await tester.tap(card(tutorialPrompts[0].answer));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('carta já acertada não pode ser marcada de novo', (tester) async {
    await pumpTutorial(tester, introFrames: const []);
    await tester.pumpAndSettle();

    await tester.tap(card(tutorialPrompts[0].answer));
    await tester.pump();
    await tester.tap(card(tutorialPrompts[0].answer)); // repetido: ignorado
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNothing);
  });
}
