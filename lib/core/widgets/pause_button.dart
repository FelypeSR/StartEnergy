import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_colors.dart';
import '../audio_controller.dart';
import 'sound_button.dart';
import 'sound_toggle_button.dart';

/// Botão circular de pausa; abre o diálogo com som e sair.
///
/// "Voltar ao menu" fecha o diálogo e dá pop na fase — pressupõe que a rota
/// abaixo é o menu (padrão do fluxo do JOGAR).
class PauseButton extends StatelessWidget {
  const PauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          AudioController.instance.playTouch();
          showDialog<void>(
            context: context,
            builder: (_) => const _PauseDialog(),
          );
        },
        child: SizedBox(
          width: 44.r,
          height: 44.r,
          child: Icon(
            Icons.pause_rounded,
            color: AppColors.electricCyan,
            size: 24.r,
          ),
        ),
      ),
    );
  }
}

class _PauseDialog extends StatelessWidget {
  const _PauseDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundTop,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Row(
        children: [
          Text(
            'Pausa',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22.sp,
            ),
          ),
          const Spacer(),
          const SoundToggleButton(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoundButton(
            label: 'Continuar',
            icon: Icons.play_arrow_rounded,
            primary: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: 12.r),
          SoundButton(
            label: 'Voltar ao menu',
            icon: Icons.exit_to_app_rounded,
            // Fecha o diálogo e sai da fase (a rota abaixo é o menu).
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
          ),
        ],
      ),
    );
  }
}
