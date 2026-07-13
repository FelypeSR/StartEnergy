import 'package:flutter_test/flutter_test.dart';
import 'package:startenergy/core/widgets/game_background.dart';
import 'package:startenergy/core/widgets/sheet_sprite.dart';
import 'package:startenergy/core/widgets/speech_balloon.dart';
import 'package:startenergy/features/level1/leideohm_screen.dart';

import 'test_app.dart';

void main() {
  testWidgets('tela da Lei de Ohm monta fundo, fórmula e a guia', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const LeiDeOhmScreen()));
    await tester.pump();

    expect(find.byType(GameBackground), findsOneWidget);
    expect(find.text('V = R · I'), findsOneWidget);
    expect(find.byType(ProfessorWidget), findsOneWidget);
    expect(find.byType(SpeechBalloon), findsOneWidget);
    expect(find.byType(SheetSprite), findsOneWidget);
  });

  testWidgets('toque na tela conclui a fase (saída provisória)', (
    tester,
  ) async {
    var finished = false;
    await tester.pumpWidget(
      testApp(LeiDeOhmScreen(onFinished: () => finished = true)),
    );
    await tester.pump();

    await tester.tap(find.byType(GameBackground));
    expect(finished, isTrue);
  });
}
