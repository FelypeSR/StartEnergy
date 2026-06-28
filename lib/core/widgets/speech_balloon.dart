import 'package:flutter/material.dart';

/// Balão de fala desenhado (sem sprite): retângulo arredondado com um rabicho
/// apontando para o personagem (canto inferior direito).
///
/// Usado na cutscene de introdução e reutilizável em qualquer fala de
/// personagem. O texto é passado por [text]; o efeito de digitação fica a cargo
/// de quem usa o widget (basta atualizar [text] gradualmente).
class SpeechBalloon extends StatelessWidget {
  const SpeechBalloon({
    super.key,
    required this.text,
    this.showContinueHint = false,
    this.isLast = false,
  });

  /// Texto exibido no balão.
  final String text;

  /// Mostra a dica de toque quando a fala termina de aparecer.
  final bool showContinueHint;

  /// Último quadro da sequência: troca a dica para "começar".
  final bool isLast;

  static const Color _ink = Color(0xFF15233B);
  static const Color _hint = Color(0xFF5B6B82);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _BalloonPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            // Sempre presente para manter a altura estável; só a opacidade muda.
            Opacity(
              opacity: showContinueHint ? 1 : 0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLast ? 'Toque para começar' : 'Toque para continuar',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _hint,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.touch_app_outlined,
                      size: 14,
                      color: _hint,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  const _BalloonPainter();

  static const double _radius = 22;
  static const double _tailWidth = 26;
  static const double _tailHeight = 16;
  static const double _tailCenterFromRight = 96;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyHeight = size.height - _tailHeight;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, bodyHeight),
      const Radius.circular(_radius),
    );

    final tailX = size.width - _tailCenterFromRight;
    final path = Path()..addRRect(body);
    path
      ..moveTo(tailX - _tailWidth / 2, bodyHeight - 1)
      ..lineTo(tailX, bodyHeight + _tailHeight)
      ..lineTo(tailX + _tailWidth / 2, bodyHeight - 1)
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.4), 8, false);
    canvas.drawPath(path, Paint()..color = const Color(0xF2F4F7FB));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x33102A4C),
    );
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter oldDelegate) => false;
}