import 'quiz_models.dart';

/// ARQUIVO EDITÁVEL: questões do Quiz 1 (level 1).
///
/// Fonte: `Questsquiz.md` (Felipe). `answerIndex` aponta a alternativa
/// correta na lista `options` — a ordem em tela é sorteada pela `QuizScreen`,
/// então a posição aqui não importa.
const List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    text: 'O que acontece quando dois Prótons '
        '(duas cargas positivas) chegam perto?',
    options: [
      'Eles viram elétrons.',
      'Eles se atraem.',
      'Eles se repelem e se afastam!',
    ],
    answerIndex: 2,
  ),
  QuizQuestion(
    text: 'Para a eletricidade fluir, precisamos de um caminho '
        'fechado chamado...',
    options: [
      'Buraco negro',
      'Circuito elétrico',
      'Campo magnético',
    ],
    answerIndex: 1,
  ),
  QuizQuestion(
    text: 'Se um fio estiver quebrado no circuito, o que acontece?',
    options: [
      'A energia passa normalmente',
      'A lâmpada acende mais forte',
      'A corrente para de passar!',
    ],
    answerIndex: 2,
  ),
  QuizQuestion(
    text: 'Quando a corrente elétrica passa por um fio, '
        'o que realmente está se movendo?',
    options: [
      'Prótons',
      'Nêutrons',
      'Elétrons',
    ],
    answerIndex: 2,
  ),
  QuizQuestion(
    text: 'Se tirarmos a pilha do circuito, o que acontece?',
    options: [
      'Tudo continua funcionando',
      'A corrente para e a lâmpada apaga!',
      'A lâmpada explode',
    ],
    answerIndex: 1,
  ),
];
