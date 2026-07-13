import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_assets.dart';
import '../../core/audio_controller.dart';
import '../../core/characters.dart';
import '../../core/widgets/formula_card.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sheet_sprite.dart';
import '../../core/widgets/sound_button.dart';
import '../../core/widgets/speech_balloon.dart';

/// Fase da Lei de Ohm (V = R · I).
///
/// Mesmo esquema de layout da cutscene/tutorial: `Row` com o laboratório da
/// fórmula ([FormulaCard] — barras de V/R + circuito animado) à esquerda e a
/// guia (Lina + balão + botão Concluir) à direita — sem sobreposição por
/// construção.
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
      'Arraste as barras e veja: mais tensão, mais corrente — '
      'mais resistência, menos!';

  var _finished = false;

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

  void _handleFinish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.r, 14.r, 4.r, 12.r),
                  child: const FormulaCard(),
                ),
              ),
              SizedBox(
                width: 272.r,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.r),
                  child: ProfessorWidget(
                    fala: _fala,
                    pose: LinaPose.explicando,
                    height: screenHeight * 0.42,
                    action: SoundButton(
                      label: 'Concluir',
                      width: 190.r,
                      onPressed: _handleFinish,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Guia da fase: balão de fala no topo — com uma ação opcional logo abaixo —
/// e a professora Lina "no chão", mesmo arranjo anti-sobreposição da coluna
/// do Link no tutorial.
class ProfessorWidget extends StatelessWidget {
  const ProfessorWidget({
    super.key,
    required this.fala,
    this.pose = LinaPose.neutra,
    required this.height,
    this.action,
  });

  /// Texto exibido no balão.
  final String fala;

  /// Pose da Lina no sheet (ver [LinaPose]).
  final int pose;

  /// Altura do sprite (fração da tela, ex.: `screenHeight * 0.42`).
  final double height;

  /// Widget opcional exibido entre o balão e a Lina (ex.: botão de concluir).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.r),
          child: SpeechBalloon(text: fala),
        ),
        if (action != null)
          Padding(
            padding: EdgeInsets.only(top: 10.r),
            child: Center(child: action),
          ),
        // Ocupa o resto da coluna; se faltar altura (balão longo + ação), a
        // Lina encolhe via FittedBox em vez de estourar o layout.
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomRight,
              child: SheetSprite(
                asset: AppAssets.linaSprite,
                columns: LinaPose.columns,
                index: pose,
                height: height,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
