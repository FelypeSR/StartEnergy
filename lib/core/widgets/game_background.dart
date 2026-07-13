import 'package:flutter/material.dart';

import '../app_assets.dart';

/// Fundo padrão das telas: imagem de cena cobrindo a tela ([asset]; por
/// padrão a sala de aula), com um scrim escuro em gradiente para garantir
/// contraste do conteúdo.
class GameBackground extends StatelessWidget {
  const GameBackground({
    super.key,
    this.asset = AppAssets.backgroundGame,
    required this.child,
  });

  /// Imagem de fundo (ex.: `AppAssets.backgroundLevel1` nas fases).
  final String asset;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xCC0A0E21),
                Color(0x660A0E21),
                Color(0xE60A0E21),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
