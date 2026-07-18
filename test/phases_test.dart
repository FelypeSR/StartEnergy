import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startenergy/features/level3/dragdrop_screen.dart';
import 'package:startenergy/features/loading/phase_loading_screen.dart';
import 'package:startenergy/features/menu/menu_screen.dart';
import 'package:startenergy/features/phases/phases_screen.dart';

import 'test_app.dart';

void main() {
  testWidgets('menu abre a seleção de fases pelo botão Fases do jogo',
      (tester) async {
    await tester.pumpWidget(testApp(const MenuScreen()));
    await tester.tap(find.text('Fases do jogo'));
    await tester.pumpAndSettle();

    expect(find.byType(PhasesScreen), findsOneWidget);
  });

  testWidgets('seleção mostra as 4 fases e o Voltar', (tester) async {
    await tester.pumpWidget(testApp(const PhasesScreen()));

    expect(find.text('Quiz das Partículas'), findsOneWidget);
    expect(find.text('Quiz da Corrente'), findsOneWidget);
    expect(find.text('Lei de Ohm'), findsOneWidget);
    expect(find.text('Montagem de Circuitos'), findsOneWidget);
    expect(find.text('Voltar'), findsOneWidget);
  });

  testWidgets('Voltar retorna ao menu', (tester) async {
    await tester.pumpWidget(testApp(const MenuScreen()));
    await tester.tap(find.text('Fases do jogo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.byType(PhasesScreen), findsNothing);
    expect(find.byType(MenuScreen), findsOneWidget);
  });

  testWidgets('tocar numa fase abre o loading e chega na fase',
      (tester) async {
    await tester.pumpWidget(testApp(const PhasesScreen()));
    await tester.tap(find.text('Montagem de Circuitos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(PhaseLoadingScreen), findsOneWidget);

    // Deixa o loading terminar (timer do minDuration) e navegar pra fase.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.byType(DragDropScreen), findsOneWidget);
  });
}
