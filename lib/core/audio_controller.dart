import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'app_assets.dart';

/// Controla a música de fundo e os efeitos sonoros do jogo.
///
/// Instância única ([instance]) compartilhada entre as telas para que o estado
/// de som persista durante toda a sessão. O liga/desliga ([enabled]) controla
/// apenas a MÚSICA — os efeitos de toque sempre tocam. O estado é mantido em
/// memória; persistência entre sessões (shared_preferences) fica como TODO.
class AudioController extends ChangeNotifier {
  AudioController._() {
    // O player de efeitos não deve roubar o foco de áudio: assim um toque nunca
    // pausa/interrompe a música (Android: audioFocus.none; iOS: mixWithOthers).
    _sfxPlayer.setAudioContext(_sfxAudioContext).catchError((_) {});
  }

  static final AudioController instance = AudioController._();

  /// Música do menu/início (loop).
  final AudioPlayer _player = AudioPlayer();

  /// Música de cena (cutscene, tutorial, fases), tocada no lugar da do menu.
  final AudioPlayer _scenePlayer = AudioPlayer();

  /// Player dedicado a efeitos curtos (toques), para não interromper a música.
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _enabled = true;
  bool _started = false;

  /// Asset da música de cena em execução (null = nenhuma; toca a do menu).
  String? _sceneAsset;

  /// Música ligada/desligada (reflete no botão de toggle). Não afeta os SFX.
  bool get enabled => _enabled;

  /// Inicia a música em loop. Idempotente: chamadas repetidas são ignoradas.
  ///
  /// Deve ser chamado a partir de uma interação do usuário (ex.: toque na tela
  /// de início), já que navegadores bloqueiam autoplay antes de um gesto.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_enabled ? _kVolume : 0);
    await _player.play(AssetSource(AppAssets.backgroundSong));
  }

  /// Inicia a música de cena [asset] em loop e pausa a música do menu (para
  /// não sobrepor). Idempotente por asset; trocar de cena troca a música.
  /// Respeita o mudo via volume.
  Future<void> startSceneMusic(String asset) async {
    if (_sceneAsset == asset) return;
    final wasInScene = _sceneAsset != null;
    _sceneAsset = asset;
    try {
      if (_started && !wasInScene) await _player.pause();
      await _scenePlayer.stop();
      await _scenePlayer.setReleaseMode(ReleaseMode.loop);
      await _scenePlayer.setVolume(_enabled ? _kVolume : 0);
      await _scenePlayer.play(AssetSource(asset));
    } catch (_) {
      // som não deve quebrar a tela (ex.: ambiente de teste sem áudio)
    }
  }

  /// Para a música de cena [asset] e retoma a música do menu.
  ///
  /// Só age se [asset] ainda for a cena atual: numa transição de tela
  /// (ex.: cutscene → tutorial) a nova cena inicia a música ANTES de a
  /// anterior ser descartada, e o dispose da antiga não deve derrubá-la.
  Future<void> stopSceneMusic(String asset) async {
    if (_sceneAsset != asset) return;
    _sceneAsset = null;
    try {
      await _scenePlayer.stop();
      if (_started) await _player.resume();
    } catch (_) {
      // ignorado de propósito
    }
  }

  /// Toca o efeito de toque em botão. Toca SEMPRE (independente do mudo).
  Future<void> playTouch() => _playSfx(AppAssets.touchSfx);

  /// Toca o efeito de toque na tela durante a cutscene (avançar/revelar fala).
  /// Toca SEMPRE (independente do mudo).
  Future<void> playTouchScene() => _playSfx(AppAssets.touchSceneSfx);

  /// Dispara um efeito curto no [_sfxPlayer], sem interromper a música.
  ///
  /// Falhas de SFX são silenciadas: um som que não toca não deve quebrar a UI
  /// (ex.: plataforma sem áudio ou ambiente de teste).
  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset), volume: _kSfxVolume);
    } catch (_) {
      // ignorado de propósito
    }
  }

  /// Alterna o mudo da música.
  Future<void> toggle() => setEnabled(!_enabled);

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;
    final volume = _enabled ? _kVolume : 0.0;
    try {
      // Só mexe nos players já tocando; senão start/startSceneMusic aplicam.
      if (_started) await _player.setVolume(volume);
      if (_sceneAsset != null) await _scenePlayer.setVolume(volume);
    } catch (_) {
      // ignorado de propósito
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _scenePlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  /// Contexto do player de efeitos: não solicita foco de áudio, para que um
  /// toque jamais pause a música em andamento.
  static final AudioContext _sfxAudioContext = AudioContext(
    android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  /// Volume baixo, adequado para música de fundo.
  static const double _kVolume = 0.4;

  /// Efeitos de toque um pouco mais altos que a música.
  static const double _kSfxVolume = 0.7;
}