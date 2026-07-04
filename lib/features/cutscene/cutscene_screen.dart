import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    AudioController.instance.startSceneMusic(AppAssets.cutsceneSong);
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
    AudioController.instance.stopSceneMusic(AppAssets.cutsceneSong);
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
                // Balão e personagem dividem a tela num Row: o balão fica com
                // o espaço à esquerda e o personagem com a coluna da direita,
                // "no chão" — assim o balão nunca cobre o rosto, em qualquer
                // tamanho de tela ou comprimento de fala.
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Balão de fala — topo, encostado no personagem (o
                      // rabicho fica a 96dp da borda direita, apontando p/
                      // ele). O AnimatedBuilder isola o rebuild da digitação
                      // só no balão, sem reconstruir o personagem.
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16.r, 12.r, 8.r, 0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 700.r),
                              child: AnimatedBuilder(
                                animation: _typeController,
                                builder: (context, _) {
                                  final full = _frame.text;
                                  final shown = full.substring(
                                    0,
                                    (full.length * _typeController.value)
                                        .round(),
                                  );
                                  return SpeechBalloon(
                                    text: shown,
                                    showContinueHint:
                                        !_typeController.isAnimating,
                                    isLast: _isLast,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Personagem — sprite sheet: a pose troca conforme o
                      // quadro atual (spriteIndex).
                      Padding(
                        padding: EdgeInsets.only(right: 16.r),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SheetSprite(
                            asset: _frame.characterSprite,
                            columns: _frame.spriteColumns,
                            index: _frame.spriteIndex,
                            height: screenHeight * 0.62,
                            // O sheet (Link.png) já tem boa folga lateral
                            // entre as poses (sem respingo → sideTrim 0).
                            // Aparamos o vão transparente sob os pés (p/
                            // encostar no chão) e acima da cabeça (p/ a caixa
                            // do sprite corresponder ao desenho). O desenho
                            // ocupa as linhas ~18%–67% da célula; 0.62 da
                            // altura da tela dá o mesmo tamanho visível que
                            // 0.82 dava sem o topTrim.
                            topTrim: 0.17,
                            bottomTrim: 0.31,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Botão pular — canto superior esquerdo.
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: _SkipButton(onSkip: _finish),
                  ),
                ),

                // Botão de mudo (música) — canto superior direito.
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: const SoundToggleButton(),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fast_forward_rounded,
                size: 18.r,
                color: AppColors.electricCyan,
              ),
              SizedBox(width: 6.r),
              Text(
                'Pular',
                style: TextStyle(
                  fontSize: 14.sp,
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