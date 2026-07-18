import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_assets.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';
import '../../core/widgets/sound_toggle_button.dart';
import '../level1/leideohm_screen.dart';
import '../level1/quiz_screen.dart';
import '../level2/quiz2_script.dart';
import '../level3/dragdrop_screen.dart';
import '../loading/phase_loading_screen.dart';

/// Seleção direta de fases (botão "Fases do jogo" do menu).
///
/// Cada botão abre a fase em si, sem as cutscenes/tutorial do fluxo do JOGAR
/// — acesso rápido para rejogar (e para testar). Ao terminar, a fase volta
/// para esta tela.
class PhasesScreen extends StatelessWidget {
  const PhasesScreen({super.key});

  static const _loadingBeat = Duration(milliseconds: 1400);

  MaterialPageRoute<void> _route(Widget Function() builder) =>
      MaterialPageRoute<void>(builder: (_) => builder());

  /// Abre uma fase via loading; o `finish` recebido pela fase volta pra cá.
  void _openPhase(
    NavigatorState navigator,
    Widget Function(VoidCallback finish) phase,
  ) {
    navigator.push(
      _route(
        () => PhaseLoadingScreen(
          minDuration: _loadingBeat,
          onFinished: () => navigator.pushReplacement(
            _route(() => phase(() => navigator.pop())),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: const SoundToggleButton(),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 20.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Fases do jogo',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 20.r),
                      SoundButton(
                        label: 'Quiz das Partículas',
                        icon: Icons.quiz_rounded,
                        onPressed: () => _openPhase(
                          navigator,
                          (finish) => QuizScreen(onFinished: (_) => finish()),
                        ),
                      ),
                      SizedBox(height: 12.r),
                      SoundButton(
                        label: 'Quiz da Corrente',
                        icon: Icons.bolt_rounded,
                        onPressed: () => _openPhase(
                          navigator,
                          (finish) => QuizScreen(
                            questions: quiz2Questions,
                            music: AppAssets.level2Song,
                            onFinished: (_) => finish(),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.r),
                      SoundButton(
                        label: 'Lei de Ohm',
                        icon: Icons.science_rounded,
                        onPressed: () => _openPhase(
                          navigator,
                          (finish) => LeiDeOhmScreen(onFinished: finish),
                        ),
                      ),
                      SizedBox(height: 12.r),
                      SoundButton(
                        label: 'Montagem de Circuitos',
                        icon: Icons.cable_rounded,
                        onPressed: () => _openPhase(
                          navigator,
                          (finish) =>
                              DragDropScreen(onFinished: (_) => finish()),
                        ),
                      ),
                      SizedBox(height: 18.r),
                      SoundButton(
                        label: 'Voltar',
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => navigator.pop(),
                      ),
                    ],
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
