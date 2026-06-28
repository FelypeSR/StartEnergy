/// Um quadro da cutscene de introdução.
///
/// A cutscene é uma sequência destes quadros: cada toque na tela avança para o
/// próximo, trocando o sprite do personagem e a fala exibida no balão. Quando
/// não há mais quadros, o jogo segue para a tela inicial.
class CutsceneFrame {
  const CutsceneFrame({
    required this.characterSprite,
    required this.text,
    this.spriteColumns = 1,
    this.spriteIndex = 0,
  });

  /// Caminho do sprite (ou sprite sheet) do personagem exibido neste quadro.
  final String characterSprite;

  /// Fala mostrada no balão neste quadro.
  final String text;

  /// Número de quadros (colunas) no sprite sheet de [characterSprite].
  final int spriteColumns;

  /// Qual quadro do sheet exibir neste momento (0-based).
  final int spriteIndex;
}