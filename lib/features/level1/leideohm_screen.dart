import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_assets.dart';
import '../../core/app_colors.dart';
import '../../core/audio_controller.dart';
import '../../core/characters.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sheet_sprite.dart';
import '../../core/widgets/speech_balloon.dart';

/// Fase da Lei de Ohm (V = R · I).
///
/// Mesmo esquema de layout da cutscene/tutorial: `Row` com a coluna da
/// fórmula à esquerda e a guia (Lina + balão) à direita — sem sobreposição
/// por construção. A interação da fórmula ainda está em desenvolvimento e
/// entra em [_buildFormulaColumn].
class LeiDeOhmScreen extends StatefulWidget {
  const LeiDeOhmScreen({super.key, this.onFinished});

  /// Chamado quando a fase termina.
  final VoidCallback? onFinished;

  @override
  State<LeiDeOhmScreen> createState() => _LeiDeOhmScreenState();
}

class _LeiDeOhmScreenState extends State<LeiDeOhmScreen> {
  // TODO(falas): texto provisório — substituir pela fala final da Lina.
  static const String _fala =
      'A Lei de Ohm liga tensão, resistência e corrente: V = R · I.';

  @override
  void initState() {
    super.initState();
    AudioController.instance.startSceneMusic(AppAssets.level1Song);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.linaSprite), context);
  }

  @override
  void dispose() {
    AudioController.instance.stopSceneMusic(AppAssets.level1Song);
    super.dispose();
  }

  var _finished = false;

  // TODO: saída provisória — enquanto a mecânica da fórmula não existe,
  // qualquer toque conclui a fase (senão o jogador fica preso aqui).
  void _handleTap() {
    if (_finished) return;
    _finished = true;
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildFormulaColumn()),
                SizedBox(
                  width: 272.r,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.r),
                    child: ProfessorWidget(
                      fala: _fala,
                      pose: LinaPose.explicando,
                      height: screenHeight * 0.42,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Coluna esquerda: painel da fórmula (placeholder até a mecânica entrar).
  Widget _buildFormulaColumn() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 14.r, 4.r, 12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 12.r),
            decoration: BoxDecoration(
              color: AppColors.backgroundTop.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.electricCyan.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              'V = R · I',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.electricYellow,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Guia da fase: balão de fala no topo e a professora Lina "no chão" —
/// mesmo arranjo anti-sobreposição da coluna do Link no tutorial.
class ProfessorWidget extends StatelessWidget {
  const ProfessorWidget({
    super.key,
    required this.fala,
    this.pose = LinaPose.neutra,
    required this.height,
  });

  /// Texto exibido no balão.
  final String fala;

  /// Pose da Lina no sheet (ver [LinaPose]).
  final int pose;

  /// Altura do sprite (fração da tela, ex.: `screenHeight * 0.42`).
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.r),
          child: SpeechBalloon(text: fala),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: SheetSprite(
            asset: AppAssets.linaSprite,
            columns: LinaPose.columns,
            index: pose,
            height: height,
          ),
        ),
      ],
    );
  }
}
