import 'package:flutter/material.dart';

/// Paleta central do StartEnergy.
///
/// Tema "energia/eletricidade": fundo noturno profundo com acentos elétricos.
/// Ajustar aqui quando o design do Figma for finalizado — todas as telas
/// devem referenciar estes tokens em vez de cores literais.
abstract final class AppColors {
  // Fundo
  static const Color backgroundTop = Color(0xFF0A0E21);
  static const Color backgroundBottom = Color(0xFF161B3D);

  // Acentos elétricos
  static const Color electricYellow = Color(0xFFFFD60A);
  static const Color electricCyan = Color(0xFF22D3EE);

  // Menu
  static const Color menuBlue = Color(0xFF1E90FF);

  // Texto
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  /// Gradiente padrão de fundo das telas.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundTop, backgroundBottom],
  );
}