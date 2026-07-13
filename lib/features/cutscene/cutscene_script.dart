import '../../core/app_assets.dart';
import '../../core/characters.dart';
import 'cutscene_frame.dart';

/// Roteiro da cutscene de introdução (tutorial/contexto do jogo).
///
/// O Link vem de um sprite sheet com 3 poses — ver [LinkPose].
///
/// TODO(falas): textos provisórios — SUBSTITUIR pelas falas finais.
const List<CutsceneFrame> introCutscene = [
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.acenando,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text: 'Olá! Eu vou te acompanhar nesta jornada pelo mundo da eletricidade.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.pensativo,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'A primeira parte do jogo é um mini quiz de cartas, onde você vai '
        'identificar e aprender as noções básicas de eletricidade.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.apresentando,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text: 'Preparado? Então vamos começar!',
  ),
];
