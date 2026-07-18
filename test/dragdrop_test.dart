import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startenergy/features/level3/circuit_models.dart';
import 'package:startenergy/features/level3/dragdrop_screen.dart';
import 'package:startenergy/features/level3/dragdrop_script.dart';

import 'test_app.dart';

/// Arrasta a peça [component] do tray até a lacuna do lado [side].
///
/// Sem `pumpAndSettle` depois que o circuito liga — o Ticker dos elétrons
/// roda sem fim enquanto `powered` (padrão do `leideohm_test.dart`).
Future<void> dragPiece(
  WidgetTester tester,
  CircuitComponent component,
  SlotSide side,
) async {
  final piece = find.byKey(ValueKey('tray-${component.name}'));
  final slot = find.byKey(ValueKey('slot-${side.name}'));
  await tester.drag(
    piece,
    tester.getCenter(slot) - tester.getCenter(piece),
  );
  await tester.pump();
}

/// Monta a quest [quest] inteira na ordem dos slots.
Future<void> solveQuest(WidgetTester tester, CircuitQuest quest) async {
  for (final slot in quest.slots) {
    await dragPiece(tester, slot.expected, slot.side);
  }
}

/// Espera o beat do circuito ligado e o avanço para a próxima quest.
Future<void> pumpPoweredBeat(WidgetTester tester) async {
  await tester.pump(
    DragDropScreen.poweredBeat + const Duration(milliseconds: 50),
  );
  await tester.pump();
}

void main() {
  testWidgets('mostra a quest 1 com tray e lacunas', (tester) async {
    await tester.pumpWidget(
      testApp(DragDropScreen(random: Random(1))),
    );
    await tester.pump();

    expect(find.text('Circuito 1 de 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('tray-battery')), findsOneWidget);
    expect(find.byKey(const ValueKey('tray-bulb')), findsOneWidget);
    expect(find.byKey(const ValueKey('tray-wire')), findsOneWidget);
    expect(find.byKey(const ValueKey('slot-left')), findsOneWidget);
    expect(find.byKey(const ValueKey('slot-top')), findsOneWidget);
    expect(find.byKey(const ValueKey('slot-right')), findsOneWidget);
  });

  testWidgets('peça certa encaixa: some do tray e a lacuna fecha',
      (tester) async {
    await tester.pumpWidget(
      testApp(DragDropScreen(random: Random(1))),
    );
    await tester.pump();

    await dragPiece(tester, CircuitComponent.battery, SlotSide.left);

    expect(find.byKey(const ValueKey('tray-battery')), findsNothing);
    expect(find.byKey(const ValueKey('slot-left')), findsNothing);
  });

  testWidgets('peça errada volta ao tray e a lacuna continua vazia',
      (tester) async {
    await tester.pumpWidget(
      testApp(DragDropScreen(random: Random(1))),
    );
    await tester.pump();

    await dragPiece(tester, CircuitComponent.wire, SlotSide.left);
    // Deixa o balanço da lacuna terminar.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('tray-wire')), findsOneWidget);
    expect(find.byKey(const ValueKey('slot-left')), findsOneWidget);
  });

  testWidgets('completa as 4 quests e reporta os resultados no Continuar',
      (tester) async {
    List<QuestResult>? reported;
    await tester.pumpWidget(
      testApp(
        DragDropScreen(
          random: Random(1),
          onFinished: (results) => reported = results,
        ),
      ),
    );
    await tester.pump();

    for (var i = 0; i < dragQuests.length; i++) {
      expect(find.text('Circuito ${i + 1} de 4'), findsOneWidget);
      // Um erro proposital na quest 2 (fio na lacuna do interruptor).
      if (i == 1) {
        await dragPiece(tester, CircuitComponent.resistor, SlotSide.right);
        await tester.pump(const Duration(milliseconds: 500));
      }
      await solveQuest(tester, dragQuests[i]);
      await pumpPoweredBeat(tester);
    }

    expect(find.text('Circuitos montados!'), findsOneWidget);
    expect(find.text('Você montou 3 de 4 sem errar!'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(reported, isNotNull);
    expect(reported!.length, 4);
    expect(reported![0].perfect, isTrue);
    expect(reported![1].perfect, isFalse);
    expect(reported![1].mistakes, 1);
    expect(reported![2].perfect, isTrue);
    expect(reported![3].perfect, isTrue);
  });

  testWidgets('distrator não encaixa em lacuna nenhuma', (tester) async {
    await tester.pumpWidget(
      testApp(DragDropScreen(random: Random(1))),
    );
    await tester.pump();

    // Avança para a quest 4 (cobre × borracha/madeira).
    for (var i = 0; i < 3; i++) {
      await solveQuest(tester, dragQuests[i]);
      await pumpPoweredBeat(tester);
    }
    expect(find.text('Circuito 4 de 4'), findsOneWidget);

    await dragPiece(tester, CircuitComponent.rubber, SlotSide.right);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('slot-right')), findsOneWidget);
    expect(find.byKey(const ValueKey('tray-rubber')), findsOneWidget);
  });
}
