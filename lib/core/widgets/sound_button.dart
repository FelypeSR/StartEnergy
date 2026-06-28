import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../audio_controller.dart';

/// Botão padrão do jogo: fundo azul (#1E90FF), texto branco e **som de toque**
/// ao ser pressionado.
///
/// [primary] aumenta o destaque (tamanho/sombra) para a ação principal de uma
/// tela. O som respeita o liga/desliga global do [AudioController].
class SoundButton extends StatelessWidget {
  const SoundButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.controller,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  /// Controlador de áudio; por padrão a instância global.
  final AudioController? controller;

  @override
  Widget build(BuildContext context) {
    final audio = controller ?? AudioController.instance;
    return SizedBox(
      width: primary ? 280 : 240,
      height: primary ? 60 : 52,
      child: ElevatedButton.icon(
        onPressed: () {
          audio.playTouch();
          onPressed();
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.menuBlue,
          foregroundColor: Colors.white,
          elevation: primary ? 8 : 3,
          shadowColor: AppColors.menuBlue.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontSize: primary ? 22 : 18,
            fontWeight: primary ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
