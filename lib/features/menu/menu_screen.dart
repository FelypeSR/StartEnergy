import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/widgets/brand_wordmark.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';
import '../../core/widgets/sound_toggle_button.dart';
import '../../core/app_assets.dart';
import '../cutscene/cutscene2.dart';
import '../cutscene/cutscene3.dart';
import '../cutscene/cutscene_screen.dart';
import '../level1/leideohm_screen.dart';
import '../level1/quiz_screen.dart';
import '../level2/quiz2_script.dart';
import '../loading/phase_loading_screen.dart';
import '../tutorial/tutorial_screen.dart';

/// Menu principal do StartEnergy (landscape).
///
/// Continuidade visual com a tela de início: mesmo fundo de sala de aula.
/// Botão de som no canto superior direito; ações ainda sem roteamento.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const _loadingBeat = Duration(milliseconds: 1400);

  MaterialPageRoute<void> _route(Widget Function() builder) =>
      MaterialPageRoute<void>(builder: (_) => builder());

  // Fluxo do JOGAR, um método por etapa (navegação provisória até existir o
  // AppRouter): cutscene do Link → tutorial → loading → Quiz 1 → cutscene 2
  // (Link, corrente elétrica) → loading → Quiz 2 → cutscene 3 (Lina) →
  // loading → Lei de Ohm → volta ao menu.
  void _startPlay(NavigatorState navigator) {
    navigator.push(
      _route(() => CutsceneScreen(onFinished: () => _toTutorial(navigator))),
    );
  }

  void _toTutorial(NavigatorState navigator) {
    navigator.pushReplacement(
      _route(() => TutorialScreen(onFinished: () => _toQuiz(navigator))),
    );
  }

  void _toQuiz(NavigatorState navigator) {
    navigator.pushReplacement(
      _route(
        () => PhaseLoadingScreen(
          minDuration: _loadingBeat,
          onFinished: () => navigator.pushReplacement(
            _route(
              () => QuizScreen(
                // TODO: endphase de revisão com os resultados; por ora
                // segue direto à cutscene 2.
                onFinished: (_) => _toCutscene2(navigator),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toCutscene2(NavigatorState navigator) {
    navigator.pushReplacement(
      _route(
        () => CutsceneScreen(
          frames: correnteCutscene,
          onFinished: () => _toQuiz2(navigator),
        ),
      ),
    );
  }

  void _toQuiz2(NavigatorState navigator) {
    navigator.pushReplacement(
      _route(
        () => PhaseLoadingScreen(
          minDuration: _loadingBeat,
          onFinished: () => navigator.pushReplacement(
            _route(
              () => QuizScreen(
                questions: quiz2Questions,
                music: AppAssets.level2Song,
                onFinished: (_) => _toCutscene3(navigator),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toCutscene3(NavigatorState navigator) {
    navigator.pushReplacement(
      _route(
        () => CutsceneScreen(
          frames: linaCutscene,
          onFinished: () => _toLeiDeOhm(navigator),
        ),
      ),
    );
  }

  void _toLeiDeOhm(NavigatorState navigator) {
    navigator.pushReplacement(
      _route(
        () => PhaseLoadingScreen(
          minDuration: _loadingBeat,
          onFinished: () => navigator.pushReplacement(
            _route(
              () => LeiDeOhmScreen(onFinished: () => navigator.pop()),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.symmetric(vertical: 24.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandWordmark(fontSize: 40),
                      SizedBox(height: 28.r),
                      SoundButton(
                        label: 'JOGAR',
                        icon: Icons.play_arrow_rounded,
                        primary: true,
                        onPressed: () => _startPlay(Navigator.of(context)),
                      ),
                      SizedBox(height: 14.r),
                      SoundButton(
                        label: 'Fases do jogo',
                        icon: Icons.flag_rounded,
                        onPressed: () {
                          // TODO: abrir a seleção de fases.
                        },
                      ),
                      SizedBox(height: 14.r),
                      SoundButton(
                        label: 'Créditos',
                        icon: Icons.info_outline_rounded,
                        onPressed: () {
                          // TODO: abrir créditos / sobre.
                        },
                      ),
                      SizedBox(height: 14.r),
                      SoundButton(
                        label: 'Sair',
                        icon: Icons.exit_to_app_rounded,
                        onPressed: () => SystemNavigator.pop(),
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
