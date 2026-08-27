import '../../core/app_assets.dart';
import '../../core/characters.dart';
import 'cutscene_frame.dart';

/// Roteiro da cutscene de introdução (tutorial/contexto do jogo).
///
/// O Link vem de um sprite sheet com 3 poses — ver [LinkPose].
const List<CutsceneFrame> introCutscene = [
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.acenando,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'Olá! Eu sou o Link e vou te acompanhar nesta jornada pelo mundo da '
        'eletricidade.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.pensativo,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'Primeiro vamos entender os conceitos sobre a eletricidade. '
        'É importante saber que ela é uma forma de energia.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.apresentando,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'Ela pode ser transformada em outras formas de energia, como luz, '
        'calor e movimento. E é gerada por meio de partículas.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.apresentando,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'Preparado? Então vamos começar! A partícula de elétron é a base da '
        'eletricidade, e ela se move através de condutores, como fios de '
        'cobre, para gerar energia elétrica.',
  ),
];
