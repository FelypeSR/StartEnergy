import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_colors.dart';
import '../audio_controller.dart';

/// Botão padrão do jogo: fundo azul (#1E90FF), texto branco e **som de toque**
/// ao ser pressionado.
///
/// [primary] aumenta o destaque (tamanho/sombra) para a ação principal de uma
/// tela. [icon] é opcional (as alternativas do quiz são só texto) e [width]
/// substitui a largura padrão. O som respeita o liga/desliga global do
/// [AudioController].
class SoundButton extends StatelessWidget {
  const SoundButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.primary = false,
    this.width,
    this.controller,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool primary;

  /// Largura do botão; por padrão a do menu (240dp, 280dp se [primary]).
  final double? width;

  /// Controlador de áudio; por padrão a instância global.
  final AudioController? controller;

  @override
  Widget build(BuildContext context) {
    final audio = controller ?? AudioController.instance;
    final icon = this.icon;

    void press() {
      audio.playTouch();
      onPressed();
    }

    final style = ElevatedButton.styleFrom(
      backgroundColor: AppColors.menuBlue,
      foregroundColor: Colors.white,
      elevation: primary ? 8 : 3,
      shadowColor: AppColors.menuBlue.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      textStyle: TextStyle(
        fontSize: (primary ? 22 : 18).sp,
        fontWeight: primary ? FontWeight.w800 : FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    return SizedBox(
      width: width ?? (primary ? 280 : 240).r,
      height: (primary ? 60 : 52).r,
      child: icon == null
          ? ElevatedButton(
              onPressed: press,
              style: style,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : ElevatedButton.icon(
              onPressed: press,
              icon: Icon(icon, color: Colors.white, size: 24.r),
              label: Text(label),
              style: style,
            ),
    );
  }
}
