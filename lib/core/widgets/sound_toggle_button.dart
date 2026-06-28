import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../audio_controller.dart';

/// Botão circular de liga/desliga som.
///
/// Reflete e alterna o estado do [AudioController]. Reutilizável em qualquer
/// tela — por padrão usa a instância global.
class SoundToggleButton extends StatelessWidget {
  const SoundToggleButton({super.key, this.controller});

  /// Controlador a usar; por padrão a instância global ([AudioController.instance]).
  final AudioController? controller;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? AudioController.instance;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final enabled = controller.enabled;
        return Semantics(
          button: true,
          label: enabled ? 'Desligar som' : 'Ligar som',
          child: Material(
            color: Colors.black.withValues(alpha: 0.35),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: controller.toggle,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: enabled ? AppColors.menuBlue : AppColors.textMuted,
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
