/// Caminhos centralizados dos assets do StartEnergy.
///
/// Referenciar sempre por aqui evita strings mágicas espalhadas pelas telas.
abstract final class AppAssets {
  static const String _images = 'assets/images';
  static const String _audio = 'assets/audio';

  /// Fundo de sala de aula usado na tela de introdução e no menu.
  static const String backgroundGame = '$_images/backgroundgame.png';

  /// Fundo do level 1 (Quiz 1).
  static const String backgroundLevel1 = '$_images/backgroundlevel1.png';

  /// Sprite do personagem guia (primeiro personagem da cutscene de introdução).
  static const String linkSprite = '$_images/Link.png';

  /// Sprite sheet da professora Lina (guia da fase Lei de Ohm): 6 poses lado a
  /// lado, pés na mesma baseline e folga lateral — usar com `SheetSprite`
  /// (`columns: 6`, trims 0).
  static const String linaSprite = '$_images/lina.png';

  /// Animação Lottie de carregamento exibida na transição entre fases.
  static const String loadingPhaseLottie = '$_images/loading_phase.json';

  /// Cartas de partícula do quiz (tutorial e level 1).
  static const String protonCard = '$_images/proton.png';
  static const String eletronCard = '$_images/eletron.png';
  static const String neutronCard = '$_images/neutron.png';

  /// Música de fundo (loop). Caminho relativo a `assets/` para o audioplayers.
  static const String backgroundSong = 'audio/backgroundsong.mp3';

  /// Música própria da cutscene (loop). Relativo a `assets/`.
  static const String cutsceneSong = 'audio/cutscene.mp3';

  /// Efeito sonoro de toque em botões. Caminho relativo a `assets/`.
  static const String touchSfx = 'audio/touch.mp3';

  /// Efeito sonoro de toque na tela durante a cutscene. Relativo a `assets/`.
  static const String touchSceneSfx = 'audio/touchscene.mp3';

  /// Música do level 1 e do seu tutorial (loop). Relativo a `assets/`.
  static const String level1Song = 'audio/song_level1.mp3';

  /// Música do level 2 (loop). Relativo a `assets/`.
  static const String level2Song = 'audio/song_level2.mp3';
}
