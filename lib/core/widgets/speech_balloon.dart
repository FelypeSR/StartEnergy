import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: EdgeInsets.fromLTRB(22.r, 18.r, 22.r, 26.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 18.sp,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 6.r),
            // Sempre presente para manter a altura estável; só a opacidade muda.
            Opacity(
              opacity: showContinueHint ? 1 : 0,
              child: Align(
                alignment: Alignment.centerRight,
                // Encolhe a dica se o balão for estreito (ex.: tutorial),
                // em vez de estourar a largura.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLast ? 'Toque para começar' : 'Toque para continuar',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _hint,
                        ),
                      ),
                      SizedBox(width: 4.r),
                      Icon(
                        Icons.touch_app_outlined,
                        size: 14.r,
                        color: _hint,
                      ),
                    ],
                  ),
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

  // Em dp de referência; escalados via .r no paint (a escala é fixa na sessão,
  // então o shouldRepaint continua falso).
  static const double _radius = 22;
  static const double _tailWidth = 26;
  static const double _tailHeight = 16;
  static const double _tailCenterFromRight = 96;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyHeight = size.height - _tailHeight.r;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, bodyHeight),
      Radius.circular(_radius.r),
    );

    final tailX = size.width - _tailCenterFromRight.r;
    final path = Path()..addRRect(body);
    path
      ..moveTo(tailX - _tailWidth.r / 2, bodyHeight - 1)
      ..lineTo(tailX, bodyHeight + _tailHeight.r)
      ..lineTo(tailX + _tailWidth.r / 2, bodyHeight - 1)
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