import '../../core/app_assets.dart';
import '../../core/characters.dart';
import 'cutscene_frame.dart';

/// Roteiro da cutscene 4: depois do laboratório da Lei de Ohm, a Lina
/// apresenta a fase final — a montagem de circuitos (drag & drop).
///
/// O sheet da Lina dispensa trims (células justas — ver [LinaPose]).
///
/// TODO(falas): textos provisórios — SUBSTITUIR pelas falas finais.
const List<CutsceneFrame> montagemCutscene = [
  CutsceneFrame(
    characterSprite: AppAssets.linaSprite,
    spriteColumns: LinaPose.columns,
    spriteIndex: LinaPose.comemorando,
    text: 'Você dominou a Lei de Ohm! Agora vem a prova final.',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linaSprite,
    spriteColumns: LinaPose.columns,
    spriteIndex: LinaPose.explicando,
    text: 'Hora de colocar a mão na massa: vamos MONTAR circuitos de verdade!',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linaSprite,
    spriteColumns: LinaPose.columns,
    spriteIndex: LinaPose.explicando,
    text: 'Arraste cada peça até a lacuna certa. Fechou o caminho, a lâmpada acende!',
  ),
  CutsceneFrame(
    characterSprite: AppAssets.linaSprite,
    spriteColumns: LinaPose.columns,
    spriteIndex: LinaPose.rindo,
    text: 'Mas cuidado: nem toda peça pertence ao circuito. Vamos lá?',
  ),
];
