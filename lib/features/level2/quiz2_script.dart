import '../level1/quiz_models.dart';

/// ARQUIVO EDITÁVEL: questões do Quiz 2 (level 2 — corrente elétrica).
///
/// Fonte: `Questsquiz.md` (Felipe). `answerIndex` aponta a alternativa
/// correta na lista `options` — a ordem em tela é sorteada pela `QuizScreen`,
/// então a posição aqui não importa.
const List<QuizQuestion> quiz2Questions = [
  QuizQuestion(
    text: 'O que é a corrente elétrica?',
    options: [
      'O caminho por onde os elétrons passam.',
      'O movimento ordenado dos elétrons.',
      'A energia armazenada na pilha.',
    ],
    answerIndex: 1,
  ),
  QuizQuestion(
    text: 'Qual objeto abaixo precisa da corrente elétrica para funcionar?',
    options: [
      'Bola de futebol.',
      'Livro.',
      'Lanterna.',
    ],
    answerIndex: 2,
  ),
  QuizQuestion(
    text: 'O que acontece com a lâmpada se o circuito estiver aberto?',
    options: [
      'Brilha mais forte.',
      'Pisca rapidamente.',
      'Não acende.',
    ],
    answerIndex: 2,
  ),
];
