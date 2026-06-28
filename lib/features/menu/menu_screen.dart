import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/brand_wordmark.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';
import '../../core/widgets/sound_toggle_button.dart';

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
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SoundToggleButton(),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandWordmark(fontSize: 40),
                      const SizedBox(height: 28),
                      SoundButton(
                        label: 'JOGAR',
                        icon: Icons.play_arrow_rounded,
                        primary: true,
                        onPressed: () {
                          // TODO: iniciar o Quiz 1 quando a tela existir.
                        },
                      ),
                      const SizedBox(height: 14),
                      SoundButton(
                        label: 'Fases do jogo',
                        icon: Icons.flag_rounded,
                        onPressed: () {
                          // TODO: abrir a seleção de fases.
                        },
                      ),
                      const SizedBox(height: 14),
                      SoundButton(
                        label: 'Créditos',
                        icon: Icons.info_outline_rounded,
                        onPressed: () {
                          // TODO: abrir créditos / sobre.
                        },
                      ),
                      const SizedBox(height: 14),
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
