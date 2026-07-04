import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_colors.dart';

/// Marca textual "StartEnergy" em itálico, com "Energy" destacado.
///
/// Tamanho ajustável para reuso entre a tela de início e o menu.
/// [fontSize] é em dp de referência; a escala de tela é aplicada aqui dentro.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 44});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.5,
        ),
        children: const [
          TextSpan(
            text: 'Start',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          TextSpan(
            text: 'Energy',
            style: TextStyle(color: AppColors.electricYellow),
          ),
        ],
      ),
    );
  }
}
