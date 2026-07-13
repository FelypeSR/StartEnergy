import '../../core/app_assets.dart';
import 'cutscene_frame.dart';

/// Roteiro da cutscene de introdução (tutorial/contexto do jogo).
///
/// O personagem vem de um sprite sheet com 3 poses ([_linkColumns]):
/// 0 = segurando energia / acenando · 1 = pensativo ("?") · 2 = apresentando.
///
/// TODO(falas): textos provisórios — SUBSTITUIR pelas falas finais.
const int _linkColumns = 3;

// O sheet (Link.png) tem boa folga lateral entre as poses (sem respingo →
// sideTrim 0). Aparamos o vão transparente sob os pés (p/ encostar no chão) e
// acima da cabeça (p/ a caixa do sprite corresponder ao desenho): o desenho
// ocupa as linhas ~18%–67% da célula.
const double _linkTopTrim = 0.17;
const double _linkBottomTrim = 0.31;

const List<CutsceneFrame> introCutscene = [
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: _linkColumns,
    spriteIndex: 0,
    topTrim: _linkTopTrim,
    bottomTrim: _linkBottomTrim,
    text: 'Olá! Eu vou te acompanhar nesta jornada pelo mundo da eletricidade.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: _linkColumns,
    spriteIndex: 1,
    topTrim: _linkTopTrim,
    bottomTrim: _linkBottomTrim,
    text:
        'A primeira parte do jogo é um mini quiz de cartas, onde você vai '
        'identificar e aprender as noções básicas de eletricidade.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: _linkColumns,
    spriteIndex: 2,
    topTrim: _linkTopTrim,
    bottomTrim: _linkBottomTrim,
    text: 'Preparado? Então vamos começar!',
  ),
];
