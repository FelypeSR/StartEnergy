import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'app_assets.dart';

/// Controla a música de fundo do jogo.
///
/// Instância única ([instance]) compartilhada entre as telas para que o estado
/// de som persista durante toda a sessão. O estado liga/desliga é mantido em
/// memória — persistência entre sessões (shared_preferences) fica como TODO.
class AudioController extends ChangeNotifier {
  AudioController._();

  static final AudioController instance = AudioController._();

  final AudioPlayer _player = AudioPlayer();

  /// Player dedicado a efeitos curtos (ex.: toque em botão), para não
  /// interromper a música de fundo.
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _enabled = true;
  bool _started = false;

  /// Som ligado/desligado (reflete no widget de toggle).
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

  /// Toca o efeito de toque em botão. Respeita o liga/desliga som.
  ///
  /// Falhas de SFX são silenciadas: um som que não toca não deve quebrar a UI
  /// (ex.: plataforma sem áudio ou ambiente de teste).
  Future<void> playTouch() async {
    if (!_enabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(AppAssets.touchSfx), volume: _kSfxVolume);
    } catch (_) {
      // ignorado de propósito
    }
  }

  /// Alterna o som entre ligado e desligado.
  Future<void> toggle() => setEnabled(!_enabled);

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;
    // Só mexe no player se a música já começou; senão start() aplica o volume.
    if (_started) {
      await _player.setVolume(_enabled ? _kVolume : 0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  /// Volume baixo, adequado para música de fundo.
  static const double _kVolume = 0.4;

  /// Efeitos de toque um pouco mais altos que a música.
  static const double _kSfxVolume = 0.7;
}
