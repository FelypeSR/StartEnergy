import 'package:flutter/material.dart';

/// Exibe um único quadro de um sprite sheet horizontal — quadros lado a lado,
/// todos com a mesma largura. Mantém a altura cheia e recorta a coluna [index].
///
/// Ex.: um sheet com 3 poses (`columns: 3`) e `index: 1` mostra só a do meio.
class SheetSprite extends StatelessWidget {
  const SheetSprite({
    super.key,
    required this.asset,
    required this.columns,
    required this.index,
    this.height,
  });

  /// Caminho do sprite sheet.
  final String asset;

  /// Número de quadros (colunas) no sheet.
  final int columns;

  /// Quadro a exibir (0-based).
  final int index;

  /// Altura do quadro; a largura segue a proporção da coluna.
  final double? height;

  @override
  Widget build(BuildContext context) {
    // -1 mostra a coluna mais à esquerda; +1 a mais à direita.
    final alignX = columns <= 1 ? 0.0 : -1.0 + 2.0 * index / (columns - 1);
    return ClipRect(
      child: Align(
        alignment: Alignment(alignX, 0),
        widthFactor: 1 / columns,
        child: Image.asset(
          asset,
          height: height,
          fit: BoxFit.fitHeight,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
