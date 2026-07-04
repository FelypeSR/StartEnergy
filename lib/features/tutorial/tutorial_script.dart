import '../../core/app_assets.dart';
import '../cutscene/cutscene_frame.dart';
import 'tutorial_prompt.dart';

/// Roteiro do TUTORIAL (antecede o level 1 — quiz de cartas).
///
/// ╔═══════════════════════════════════════════════════════════════════╗
/// ║  EDITE AQUI as falas do Link e as dicas do painel.                 ║
/// ║  Poses do Link (spriteIndex): 0 = acenando · 1 = pensativo ·       ║
/// ║  2 = apresentando.                                                 ║
/// ║  O balão do tutorial é mais estreito que o da cutscene — prefira   ║
/// ║  falas CURTAS (1–2 linhas).                                        ║
/// ╚═══════════════════════════════════════════════════════════════════╝
///
/// TODO(falas): textos provisórios — substituir pelas falas finais.
const int _linkColumns = 3;

/// Balões introdutórios, mostrados ANTES de as cartas caírem.
/// Cada toque na tela avança para a próxima fala.
const List<CutsceneFrame> tutorialIntro = [
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: _linkColumns,
    spriteIndex: 0,
    text: 'Chegamos à bancada de treino! Aqui você conhece as cartas de partícula.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: _linkColumns,
    spriteIndex: 2,
    text: 'Leia as dicas do quadro e toque nas cartas na ordem certa.',
  ),
];

/// Fala exibida enquanto o jogador interage com as cartas.
const CutsceneFrame tutorialPlayFrame = CutsceneFrame(
  characterSprite: AppAssets.linkSprite,
  spriteColumns: _linkColumns,
  spriteIndex: 2,
  text: 'Vamos lá: toque nas cartas na ordem correta.',
);

/// Fala final, após acertar todas as cartas. Um toque segue o jogo.
const CutsceneFrame tutorialDoneFrame = CutsceneFrame(
  characterSprite: AppAssets.linkSprite,
  spriteColumns: _linkColumns,
  spriteIndex: 0,
  text: 'Mandou bem! Agora você está pronto para a primeira fase.',
);

/// Dicas do painel, NA ORDEM em que as cartas devem ser tocadas.
const List<TutorialPrompt> tutorialPrompts = [
  TutorialPrompt(text: 'Partícula com carga negativa.', answer: Particle.eletron),
  TutorialPrompt(text: 'Partícula com carga positiva.', answer: Particle.proton),
  TutorialPrompt(text: 'Partícula sem carga.', answer: Particle.neutron),
];
