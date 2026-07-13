import 'dart:math';

/// Uma questão do quiz: enunciado, alternativas e o índice da correta.
class QuizQuestion {
  const QuizQuestion({
    required this.text,
    required this.options,
    required this.answerIndex,
  });

  final String text;
  final List<String> options;

  /// Índice da alternativa correta em [options].
  final int answerIndex;
}

/// Resposta dada a uma questão — gravada para a revisão dos erros no fim da
/// fase (endphase). O quiz avança independente de acerto/erro.
class AnswerResult {
  const AnswerResult({required this.question, required this.selectedIndex});

  final QuizQuestion question;
  final int selectedIndex;

  bool get correct => selectedIndex == question.answerIndex;
}

/// Ordem de exibição das alternativas, sorteada de novo a cada questão
/// (anti-decoreba: as posições mudam a cada passagem).
List<int> shuffledOrder(int length, Random random) =>
    List<int>.generate(length, (i) => i)..shuffle(random);

/// Estrelas da fase pelo total de acertos: tudo certo vale 3, pelo menos
/// metade vale 2, pelo menos um acerto vale 1 (zero acertos, zero estrelas).
/// Nas 5 questões do Quiz 1: 5 → 3 · 4–3 → 2 · 2–1 → 1.
int starsForCorrect(int correct, int total) {
  if (correct >= total) return 3;
  if (correct * 2 >= total) return 2;
  if (correct > 0) return 1;
  return 0;
}