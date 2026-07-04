import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/widgets/brand_wordmark.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';
import '../../core/widgets/sound_toggle_button.dart';
import '../cutscene/cutscene_screen.dart';
import '../tutorial/tutorial_screen.dart';

/// Menu principal do StartEnergy (landscape).
///
/// Continuidade visual com a tela de início: mesmo fundo de sala de aula.
/// Botão de som no canto superior direito; ações ainda sem roteamento.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

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
                        onPressed: () {
                          // Fluxo do JOGAR: cutscene → tutorial → level 1.
                          // (Navegação provisória até existir o AppRouter.)
                          final navigator = Navigator.of(context);
                          navigator.push(
                            MaterialPageRoute<void>(
                              builder: (_) => CutsceneScreen(
                                onFinished: () => navigator.pushReplacement(
                                  MaterialPageRoute<void>(
                                    builder: (_) => TutorialScreen(
                                      // TODO: seguir para o level 1 quando
                                      // ele existir; por ora volta ao menu.
                                      onFinished: () => navigator.pop(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
