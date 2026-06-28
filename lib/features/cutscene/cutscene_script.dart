import '../../core/app_assets.dart';
import 'cutscene_frame.dart';

/// Roteiro da cutscene de introdução (tutorial/contexto do jogo).
///
/// O personagem vem de um sprite sheet com 3 poses ([_linkColumns]):
/// 0 = segurando energia / acenando · 1 = pensativo ("?") · 2 = apresentando.
///
/// TODO(falas): textos provisórios — SUBSTITUIR pelas falas finais.
const int _linkColumns = 3;

const List<CutsceneFrame> introCutscene = [
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: _linkColumns,
    spriteIndex: 0,
    text: 'Olá! Eu vou te acompanhar nesta jornada pelo mundo da eletricidade.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: _linkColumns,
    spriteIndex: 1,
    text:
        'A primeira parte do jogo é um mini quiz de cartas, onde você vai '
        'identificar e aprender as noções básicas de eletricidade.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: _linkColumns,
    spriteIndex: 2,
    text: 'Preparado? Então vamos começar!',
  ),
];
