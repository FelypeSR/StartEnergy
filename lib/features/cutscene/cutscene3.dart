import '../../core/app_assets.dart';
import '../../core/characters.dart';
import 'cutscene_frame.dart';

/// Roteiro da cutscene 3: a Lina assume como guia depois do Quiz 1 e
/// apresenta a fase da Lei de Ohm.
///
/// O sheet da Lina dispensa trims (células justas — ver [LinaPose]).
///
/// TODO(falas): textos provisórios — SUBSTITUIR pelas falas finais.
const List<CutsceneFrame> linaCutscene = [
  CutsceneFrame(
    characterSprite: AppAssets.linaSprite,
    spriteColumns: LinaPose.columns,
    spriteIndex: LinaPose.acenando,
    text: 'Oi! Eu sou a Lina, a professora daqui!',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linaSprite,
    spriteColumns: LinaPose.columns,
    spriteIndex: LinaPose.comemorando,
    text: 'Parabéns pelo quiz! Você já conhece o básico da eletricidade.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linaSprite,
    spriteColumns: LinaPose.columns,
    spriteIndex: LinaPose.explicando,
    text:
        'Agora vem a Lei de Ohm: V = R · I — tensão, resistência e corrente.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linaSprite,
    spriteColumns: LinaPose.columns,
    spriteIndex: LinaPose.rindo,
    text: 'Vamos ver isso na prática?',
  ),
];
