import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Exibe um único quadro de um sprite sheet horizontal — quadros lado a lado,
/// todos com a mesma largura. Recorta a coluna [index] e a pinta via
/// [Canvas.drawImageRect].
///
/// Diferente de um clip por `Align/widthFactor`, aqui a célula pode ser
/// **aparada** nas bordas ([sideTrim]/[bottomTrim]/[topTrim], frações da
/// célula). Isso é necessário quando as poses do sheet encostam na emenda
/// (respingo da pose vizinha) ou deixam espaço transparente sob os pés (o que
/// faria o personagem "flutuar" ao ser alinhado pela base).
///
/// Ex.: um sheet com 3 poses (`columns: 3`) e `index: 1` mostra só a do meio.
class SheetSprite extends StatefulWidget {
  const SheetSprite({
    super.key,
    required this.asset,
    required this.columns,
    required this.index,
    this.height,
    this.sideTrim = 0,
    this.topTrim = 0,
    this.bottomTrim = 0,
  });

  /// Caminho do sprite sheet.
  final String asset;

  /// Número de quadros (colunas) no sheet.
  final int columns;

  /// Quadro a exibir (0-based).
  final int index;

  /// Altura do quadro (já aparado); a largura segue a proporção.
  final double? height;

  /// Fração da célula aparada em CADA lado (mata respingo da pose vizinha).
  final double sideTrim;

  /// Fração da célula aparada no topo.
  final double topTrim;

  /// Fração da célula aparada na base (remove o vão transparente sob os pés).
  final double bottomTrim;

  @override
  State<SheetSprite> createState() => _SheetSpriteState();
}

class _SheetSpriteState extends State<SheetSprite> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(SheetSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolve();
  }

  void _resolve() {
    final stream = AssetImage(
      widget.asset,
    ).resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _detach();
    _stream = stream;
    _listener = ImageStreamListener(
      (info, _) {
        if (mounted) setState(() => _image = info.image);
      },
      // Em testes o asset pode não decodificar; só ignoramos (fica o SizedBox).
      onError: (_, __) {},
    );
    stream.addListener(_listener!);
  }

  void _detach() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) {
      // Mantém o espaço reservado até o sheet decodificar (geralmente já está
      // em cache via precacheImage, então isso é só o 1º frame).
      return SizedBox(height: widget.height);
    }

    final cellW = image.width / widget.columns;
    final cellH = image.height.toDouble();
    final col = widget.index.clamp(0, widget.columns - 1);
    final src = Rect.fromLTRB(
      cellW * col + cellW * widget.sideTrim,
      cellH * widget.topTrim,
      cellW * (col + 1) - cellW * widget.sideTrim,
      cellH - cellH * widget.bottomTrim,
    );

    final aspect = src.width / src.height;
    final height = widget.height;
    return SizedBox(
      height: height,
      width: height == null ? null : height * aspect,
      child: CustomPaint(
        painter: _SheetSpritePainter(image: image, src: src),
        child: AspectRatio(aspectRatio: aspect),
      ),
    );
  }
}

class _SheetSpritePainter extends CustomPainter {
  _SheetSpritePainter({required this.image, required this.src});

  final ui.Image image;
  final Rect src;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    canvas.drawImageRect(image, src, Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_SheetSpritePainter old) =>
      old.image != image || old.src != src;
}