import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startenergy/core/app_assets.dart';
import 'package:startenergy/core/characters.dart';
import 'package:startenergy/features/cutscene/cutscene2.dart';
import 'package:startenergy/features/cutscene/cutscene_frame.dart';
import 'package:startenergy/features/cutscene/cutscene_screen.dart';

import 'test_app.dart';

void main() {
  // Sprite real (com as colunas corretas do sheet): a tela pré-carrega os
  // assets dos quadros e um caminho inexistente faria o precacheImage
  // reportar erro dentro do teste.
  const frames = [
    CutsceneFrame(
      characterSprite: AppAssets.linkSprite,
      spriteColumns: 3,
      text: 'Oi',
    ),
    CutsceneFrame(
      characterSprite: AppAssets.linkSprite,
      spriteColumns: 3,
      spriteIndex: 1,
      text: 'Fim',
    ),
  ];

  Future<void> pumpCutscene(
    WidgetTester tester, {
    required VoidCallback onFinished,
  }) {
    return tester.pumpWidget(
      testApp(CutsceneScreen(frames: frames, onFinished: onFinished)),
    );
  }

  testWidgets('avança as falas no toque e chama onFinished no fim', (
    tester,
  ) async {
    var finished = false;
    await pumpCutscene(tester, onFinished: () => finished = true);

    await tester.pumpAndSettle(); // conclui a digitação da 1ª fala
    expect(find.text('Oi'), findsOneWidget);

    await tester.tap(find.byType(CutsceneScreen));
    await tester.pumpAndSettle();
    expect(find.text('Oi'), findsNothing);
    expect(find.text('Fim'), findsOneWidget);
    expect(finished, isFalse);

    await tester.tap(find.byType(CutsceneScreen));
    await tester.pump();
    expect(finished, isTrue);
  });

  testWidgets('botão Pular conclui a cutscene imediatamente', (tester) async {
    var finished = false;
    await pumpCutscene(tester, onFinished: () => finished = true);

    await tester.tap(find.text('Pular'));
    await tester.pump();
    expect(finished, isTrue);
  });

  group('cutscene 2 (Lina)', () {
    test('todos os quadros usam o sheet da Lina com poses válidas', () {
      for (final frame in linaCutscene) {
        expect(frame.characterSprite, AppAssets.linaSprite);
        expect(frame.spriteColumns, LinaPose.columns);
        expect(
          frame.spriteIndex,
          inInclusiveRange(0, LinaPose.columns - 1),
        );
        expect(frame.text, isNotEmpty);
      }
    });

    testWidgets('toca do início ao fim no CutsceneScreen', (tester) async {
      var finished = false;
      await tester.pumpWidget(
        testApp(
          CutsceneScreen(
            frames: linaCutscene,
            onFinished: () => finished = true,
          ),
        ),
      );

      for (final frame in linaCutscene) {
        await tester.pumpAndSettle(); // conclui a digitação da fala
        expect(find.text(frame.text), findsOneWidget);
        await tester.tap(find.byType(CutsceneScreen));
      }
      await tester.pump();
      expect(finished, isTrue);
    });
  });
}
