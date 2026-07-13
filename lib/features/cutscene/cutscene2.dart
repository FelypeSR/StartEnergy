import '../../core/app_assets.dart';
import '../../core/characters.dart';
import 'cutscene_frame.dart';

/// Roteiro da cutscene 2: depois do Quiz 1, o Link explica a corrente
/// elétrica e os condutores, preparando o Quiz 2 (level 2).
///
/// Fonte das falas: `Questsquiz.md` (Felipe).
const List<CutsceneFrame> correnteCutscene = [
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.acenando,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'Agora que você compreendeu o básico, vamos começar a entender como '
        'funciona a corrente elétrica...',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.apresentando,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'A corrente elétrica acontece quando os elétrons se movimentam de '
        'forma organizada através de um condutor.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.pensativo,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'Os condutores são materiais que deixam a corrente elétrica passar '
        'com facilidade! Os elétrons conseguem se mover livremente dentro '
        'de um condutor.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linkSprite,
    spriteColumns: LinkPose.columns,
    spriteIndex: LinkPose.apresentando,
    topTrim: LinkPose.topTrim,
    bottomTrim: LinkPose.bottomTrim,
    text:
        'Cobre e alumínio são alguns dos condutores mais usados '
        'no dia a dia.',
  ),
];
