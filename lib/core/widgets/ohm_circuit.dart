import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../app_colors.dart';

/// Circuito elétrico animado: laço de fio com bateria à esquerda e resistor
/// no topo, com elétrons (pontos) percorrendo o fio. A velocidade do fluxo é
/// proporcional a [current] — corrente zero congela os elétrons.
class OhmCircuit extends StatefulWidget {
  const OhmCircuit({super.key, required this.current});

  /// Corrente em ampères (I = V ÷ R), definida pela tela.
  final double current;

  @override
  State<OhmCircuit> createState() => _OhmCircuitState();
}

class _OhmCircuitState extends State<OhmCircuit>
    with SingleTickerProviderStateMixin {
  /// Fase do fluxo (fração do laço, 0–1). ValueNotifier como `repaint` do
  /// painter: cada tick redesenha SÓ o canvas, sem rebuild da árvore.
  final ValueNotifier<double> _phase = ValueNotifier<double>(0);

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    // Fração do laço percorrida por segundo: proporcional à corrente, com
    // teto para o fluxo continuar legível em correntes altas.
    final speed = (widget.current * 0.05).clamp(0.0, 0.6);
    _phase.value = (_phase.value + dt * speed) % 1.0;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircuitPainter(phase: _phase),
      size: Size.infinite,
    );
  }
}

class _CircuitPainter extends CustomPainter {
  _CircuitPainter({required this.phase}) : super(repaint: phase);

  final ValueListenable<double> phase;

  static const int _electronCount = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(18, 18, size.width - 36, size.height - 36);
    if (rect.isEmpty) return;
    final loop = RRect.fromRectAndRadius(rect, const Radius.circular(18));

    // Fio.
    canvas.drawRRect(
      loop,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF64748B),
    );

    // Elétrons percorrendo o laço.
    final metric =
        (Path()..addRRect(loop)).computeMetrics().first;
    final dot = Paint()..color = AppColors.electricCyan;
    final glow = Paint()
      ..color = AppColors.electricCyan.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (var i = 0; i < _electronCount; i++) {
      final d = ((phase.value + i / _electronCount) % 1.0) * metric.length;
      final pos = metric.getTangentForOffset(d)!.position;
      canvas.drawCircle(pos, 5, glow);
      canvas.drawCircle(pos, 3.2, dot);
    }

    _drawBattery(canvas, rect);
    _drawResistor(canvas, rect);
    _drawCurrentArrow(canvas, rect);
  }

  /// Bateria sobre o trecho esquerdo do fio, com polos + (topo) e − (base).
  void _drawBattery(Canvas canvas, Rect rect) {
    final body = Rect.fromCenter(
      center: Offset(rect.left, rect.center.dy),
      width: 30,
      height: 72,
    );
    final rbody = RRect.fromRectAndRadius(body, const Radius.circular(7));
    canvas.drawRRect(rbody, Paint()..color = const Color(0xFF1F2937));
    canvas.drawRRect(
      rbody,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.electricYellow,
    );

    final symbol = Paint()
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.textPrimary;
    final plus = Offset(body.center.dx, body.top + 17);
    canvas.drawLine(plus.translate(-5, 0), plus.translate(5, 0), symbol);
    canvas.drawLine(plus.translate(0, -5), plus.translate(0, 5), symbol);
    final minus = Offset(body.center.dx, body.bottom - 17);
    canvas.drawLine(minus.translate(-5, 0), minus.translate(5, 0), symbol);
  }

  /// Resistor sobre o trecho superior do fio, com zigue-zague interno.
  void _drawResistor(Canvas canvas, Rect rect) {
    final body = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.top),
      width: 92,
      height: 30,
    );
    final rbody = RRect.fromRectAndRadius(body, const Radius.circular(9));
    canvas.drawRRect(rbody, Paint()..color = const Color(0xFF1F2937));
    canvas.drawRRect(
      rbody,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.electricCyan,
    );

    final zig = Path()..moveTo(body.left + 12, body.center.dy);
    const steps = 6;
    final stepW = (body.width - 24) / steps;
    for (var i = 0; i < steps; i++) {
      zig.lineTo(
        body.left + 12 + stepW * (i + 0.5),
        body.center.dy + (i.isEven ? -7 : 7),
      );
    }
    zig.lineTo(body.right - 12, body.center.dy);
    canvas.drawPath(
      zig,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = AppColors.electricYellow,
    );
  }

  /// Seta do sentido da corrente, acima do trecho superior direito do fio.
  void _drawCurrentArrow(Canvas canvas, Rect rect) {
    final y = rect.top - 12;
    final start = Offset(rect.right - 96, y);
    final end = Offset(rect.right - 52, y);
    final paint = Paint()
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.electricCyan;
    canvas.drawLine(start, end, paint);
    final head = Path()
      ..moveTo(end.dx + 7, end.dy)
      ..lineTo(end.dx - 2, end.dy - 5)
      ..lineTo(end.dx - 2, end.dy + 5)
      ..close();
    canvas.drawPath(head, Paint()..color = AppColors.electricCyan);
  }

  @override
  bool shouldRepaint(_CircuitPainter oldDelegate) =>
      phase != oldDelegate.phase;
}
