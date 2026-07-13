import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startenergy/core/widgets/sound_button.dart';
import 'package:startenergy/features/level1/quiz_models.dart';
import 'package:startenergy/features/level1/quiz_screen.dart';
import 'package:startenergy/features/level1/quiz_script.dart';

import 'test_app.dart';

/// Random que faz o shuffle virar identidade (nextInt(n) == n-1 mantém cada
/// elemento no lugar no Fisher–Yates): as alternativas aparecem na ordem do
/// script, permitindo tocar nelas deterministicamente.
class _IdentityRandom implements Random {
  @override
  int nextInt(int max) => max - 1;

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}

void main() {
  group('shuffledOrder', () {
    test('é sempre uma permutação e varia entre sorteios', () {
      final random = Random(7);
      final draws = [for (var i = 0; i < 12; i++) shuffledOrder(3, random)];
      for (final order in draws) {
        expect(order, hasLength(3));
        expect(order.toSet(), {0, 1, 2});
      }
      final distinct = draws.map((d) => d.join()).toSet();
      expect(distinct.length, greaterThan(1),
          reason: 'as posições devem mudar entre as trocas');
    });
  });

  group('starsForCorrect', () {
    test('5 acertos → 3 · 4–3 → 2 · 2–1 → 1 · 0 → 0', () {
      expect(starsForCorrect(5, 5), 3);
      expect(starsForCorrect(4, 5), 2);
      expect(starsForCorrect(3, 5), 2);
      expect(starsForCorrect(2, 5), 1);
      expect(starsForCorrect(1, 5), 1);
      expect(starsForCorrect(0, 5), 0);
    });
  });

  group('QuizScreen', () {
    /// Responde todas as questões: as [wrong] primeiras erradas, o resto certo.
    Future<void> answerAll(WidgetTester tester, {int wrong = 0}) async {
      for (var i = 0; i < quizQuestions.length; i++) {
        final q = quizQuestions[i];
        final index =
            i < wrong ? (q.answerIndex == 0 ? 1 : 0) : q.answerIndex;
        await tester.tap(find.text(q.options[index]));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('mostra o enunciado e as alternativas da 1ª questão', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(QuizScreen(random: _IdentityRandom())),
      );
      await tester.pump();

      final first = quizQuestions.first;
      expect(find.text('Questão 1 de ${quizQuestions.length}'), findsOneWidget);
      expect(find.text(first.text), findsOneWidget);
      for (final option in first.options) {
        expect(find.text(option), findsOneWidget);
      }
    });

    testWidgets('responder avança sempre, com acerto ou erro', (tester) async {
      await tester.pumpWidget(
        testApp(QuizScreen(random: _IdentityRandom())),
      );
      await tester.pump();

      // Erra a 1ª de propósito: avança mesmo assim.
      final wrongIndex = quizQuestions[0].answerIndex == 0 ? 1 : 0;
      await tester.tap(find.text(quizQuestions[0].options[wrongIndex]));
      await tester.pumpAndSettle();

      expect(find.text('Questão 2 de ${quizQuestions.length}'), findsOneWidget);
      expect(find.text(quizQuestions[1].text), findsOneWidget);
    });

    testWidgets('conclui com todos os resultados gravados após Continuar', (
      tester,
    ) async {
      List<AnswerResult>? results;
      await tester.pumpWidget(
        testApp(
          QuizScreen(
            random: _IdentityRandom(),
            onFinished: (r) => results = r,
          ),
        ),
      );
      await tester.pump();

      await answerAll(tester, wrong: 1);

      // A última resposta abre o resultado; onFinished só vem no Continuar.
      expect(results, isNull);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(results, isNotNull);
      expect(results, hasLength(quizQuestions.length));
      expect(results!.first.correct, isFalse);
      expect(results!.skip(1).every((r) => r.correct), isTrue);
    });

    testWidgets('resultado mostra 3 estrelas com tudo certo', (tester) async {
      await tester.pumpWidget(testApp(QuizScreen(random: _IdentityRandom())));
      await tester.pump();

      await answerAll(tester);

      expect(find.text('Quiz concluído!'), findsOneWidget);
      expect(
        find.text('Você acertou 5 de ${quizQuestions.length}!'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border_rounded), findsNothing);
    });

    testWidgets('resultado mostra 2 estrelas com 1 erro', (tester) async {
      await tester.pumpWidget(testApp(QuizScreen(random: _IdentityRandom())));
      await tester.pump();

      await answerAll(tester, wrong: 1);

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(1));
    });

    testWidgets('resultado mostra 1 estrela com 3 erros', (tester) async {
      await tester.pumpWidget(testApp(QuizScreen(random: _IdentityRandom())));
      await tester.pump();

      await answerAll(tester, wrong: 3);

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(1));
      expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(2));
    });

    testWidgets('alternativas usam o botão padrão do jogo', (tester) async {
      await tester.pumpWidget(
        testApp(QuizScreen(random: _IdentityRandom())),
      );
      await tester.pump();

      expect(
        find.byType(SoundButton),
        findsNWidgets(quizQuestions.first.options.length),
      );
    });
  });
}