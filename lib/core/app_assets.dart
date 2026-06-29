/// Caminhos centralizados dos assets do StartEnergy.
///
/// Referenciar sempre por aqui evita strings mágicas espalhadas pelas telas.
abstract final class AppAssets {
  static const String _images = 'assets/images';
  static const String _audio = 'assets/audio';

  /// Fundo de sala de aula usado na tela de introdução e no menu.
  static const String backgroundGame = '$_images/backgroundgame.png';

  /// Sprite do personagem guia (primeiro personagem da cutscene de introdução).
  static const String linkSprite = '$_images/Link.png';

  /// Música de fundo (loop). Caminho relativo a `assets/` para o audioplayers.
  static const String backgroundSong = 'audio/backgroundsong.mp3';

  /// Música própria da cutscene (loop). Relativo a `assets/`.
  static const String cutsceneSong = 'audio/cutscene.mp3';

  /// Efeito sonoro de toque em botões. Caminho relativo a `assets/`.
  static const String touchSfx = 'audio/touch.mp3';

  /// Efeito sonoro de toque na tela durante a cutscene. Relativo a `assets/`.
  static const String touchSceneSfx = 'audio/touchscene.mp3';
}
