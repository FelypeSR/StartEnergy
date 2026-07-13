import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startenergy/core/widgets/formula_card.dart';
import 'package:startenergy/core/widgets/game_background.dart';
import 'package:startenergy/core/widgets/ohm_circuit.dart';
import 'package:startenergy/core/widgets/sheet_sprite.dart';
import 'package:startenergy/core/widgets/speech_balloon.dart';
import 'package:startenergy/features/level1/leideohm_screen.dart';

import 'test_app.dart';

void main() {
  // O circuito anima continuamente (Ticker) — usar pump com duração
  // explícita; pumpAndSettle nunca "assentaria".
  Future<void> pumpScreen(
    WidgetTester tester, {
    VoidCallback? onFinished,
  }) async {
    await tester.pumpWidget(
      testApp(LeiDeOhmScreen(onFinished: onFinished)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  String readout(WidgetTester tester) => tester
      .widget<Text>(find.byKey(const ValueKey('current-readout')))
      .data!;

  testWidgets('tela da Lei de Ohm monta fundo, laboratório e a guia', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.byType(GameBackground), findsOneWidget);
    expect(find.byType(FormulaCard), findsOneWidget);
    expect(find.byType(OhmCircuit), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.byType(ProfessorWidget), findsOneWidget);
    expect(find.byType(SpeechBalloon), findsOneWidget);
    expect(find.byType(SheetSprite), findsOneWidget);
  });

  testWidgets('mostra a corrente inicial calculada', (tester) async {
    await pumpScreen(tester);

    // Padrão: 6,0 V ÷ 3,0 Ω = 2,0 A.
    expect(readout(tester), 'I = 2,0 A');
  });

  testWidgets('arrastar a barra da tensão recalcula a corrente', (
    tester,
  ) async {
    await pumpScreen(tester);

    // Arrasta a barra de V até o máximo (12 V): 12 ÷ 3 = 4,0 A.
    await tester.drag(find.byType(Slider).first, const Offset(600, 0));
    await tester.pump(const Duration(milliseconds: 100));

    expect(readout(tester), 'I = 4,0 A');
  });

  testWidgets('só o botão Concluir termina a fase', (tester) async {
    var finished = false;
    await pumpScreen(tester, onFinished: () => finished = true);

    // Toque no meio da tela (área do circuito) não conclui mais.
    await tester.tap(find.byType(OhmCircuit), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 50));
    expect(finished, isFalse);

    await tester.tap(find.text('Concluir'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(finished, isTrue);
  });
}