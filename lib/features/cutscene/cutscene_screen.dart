import 'package:flutter/material.dart';

import '../../core/app_assets.dart';
import '../../core/app_colors.dart';
import '../../core/audio_controller.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sheet_sprite.dart';
import '../../core/widgets/sound_toggle_button.dart';
import '../../core/widgets/speech_balloon.dart';
import 'cutscene_frame.dart';
import 'cutscene_script.dart';

/// Cutscene de introdução (tutorial/contexto), exibida antes da tela inicial.
///
/// Sequência de [CutsceneFrame]: cada toque revela a fala inteira (se ainda
/// estiver "digitando") ou avança para o próximo quadro, trocando o sprite do
/// personagem. Concluída a última fala — ou ao tocar em "Pular" — chama
/// [onFinished] para seguir o fluxo do jogo.
class CutsceneScreen extends StatefulWidget {
  const CutsceneScreen({super.key, this.frames = introCutscene, this.onFinished});

  /// Quadros da cutscene, na ordem de exibição.
  final List<CutsceneFrame> frames;

  /// Disparado ao concluir a última fala ou ao pular.
  final VoidCallback? onFinished;

  @override
  State<CutsceneScreen> createState() => _CutsceneScreenState();
}

class _CutsceneScreenState extends State<CutsceneScreen>
    with SingleTickerProviderStateMixin {
  static const int _msPerChar = 28;

  late final AnimationController _typeController;
  int _index = 0;
  bool _finished = false;
  bool _precached = false;

  CutsceneFrame get _frame => widget.frames[_index];
  bool get _isLast => _index == widget.frames.length - 1;

  @override
  void initState() {
    super.initState();
    _typeController = AnimationController(vsync: this);
    AudioController.instance.startCutsceneMusic();
    _playFrame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pré-carrega os sprites uma única vez para que a troca a cada toque seja
    // instantânea (sem hitch de decodificação na primeira exibição).
    if (_precached) return;
    _precached = true;
    precacheImage(const AssetImage(AppAssets.backgroundGame), context);
    for (final path in widget.frames.map((f) => f.characterSprite).toSet()) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  void dispose() {
    AudioController.instance.stopCutsceneMusic();
    _typeController.dispose();
    super.dispose();
  }

  void _playFrame() {
    final length = _frame.text.length;
    _typeController
      ..duration = Duration(
        milliseconds: (length * _msPerChar).clamp(400, 6000),
      )
      ..forward(from: 0);
  }

  void _handleTap() {
    if (_finished) return;
    AudioController.instance.playTouchScene();
    if (_typeController.isAnimating) {
      _typeController.value = 1; // revela a fala inteira de uma vez
      return;
    }
    if (_isLast) {
      _finish();
    } else {
      setState(() => _index++);
      _playFrame();
    }
  }

  void _finish() {
    if (_finished) return;
    setState(() => _finished = true);
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: GameBackground(
          child: SafeArea(
            child: Stack(
              children: [
                // Personagem — canto inferior direito, "no chão". É um sprite
                // sheet: a pose troca conforme o quadro atual (spriteIndex).
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SheetSprite(
                      asset: _frame.characterSprite,
                      columns: _frame.spriteColumns,
                      index: _frame.spriteIndex,
                      height: screenHeight * 0.82,
                      // O sheet (Link.png) já tem boa folga lateral entre as
                      // poses (sem respingo → sideTrim 0); só aparamos o vão
                      // transparente sob os pés p/ encostar no chão.
                      bottomTrim: 0.31,
                    ),
                  ),
                ),

                // Balão de fala — topo, com efeito de digitação. O AnimatedBuilder
                // isola o rebuild só no balão, sem reconstruir o personagem.
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: AnimatedBuilder(
                        animation: _typeController,
                        builder: (context, _) {
                          final full = _frame.text;
                          final shown = full.substring(
                            0,
                            (full.length * _typeController.value).round(),
                          );
                          return SpeechBalloon(
                            text: shown,
                            showContinueHint: !_typeController.isAnimating,
                            isLast: _isLast,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Botão pular — canto superior esquerdo.
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _SkipButton(onSkip: _finish),
                  ),
                ),

                // Botão de mudo (música) — canto superior direito.
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: SoundToggleButton(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSkip,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fast_forward_rounded,
                size: 18,
                color: AppColors.electricCyan,
              ),
              SizedBox(width: 6),
              Text(
                'Pular',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}