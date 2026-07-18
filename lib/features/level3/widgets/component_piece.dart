import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_colors.dart';
import '../circuit_models.dart';

/// Peça de circuito desenhada em código (estilo do `OhmCircuit`), usada no
/// tray (dentro de um `Draggable`), no feedback do arraste e na silhueta da
/// lacuna. Arte trocável por sprites do Figma depois — só este arquivo muda.
class ComponentPiece extends StatelessWidget {
  const ComponentPiece({
    super.key,
    required this.component,
    required this.size,
    this.showLabel = true,
  });

  final CircuitComponent component;

  /// Lado do quadrado da peça (já escalado pelo chamador, ex.: `56.r`).
  final double size;

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final art = CustomPaint(
      size: Size.square(size),
      painter: _PiecePainter(component),
    );
    if (!showLabel) return art;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        art,
        SizedBox(height: 3.r),
        Text(
          component.label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PiecePainter extends CustomPainter {
  const _PiecePainter(this.component);

  final CircuitComponent component;

  @override
  void paint(Canvas canvas, Size size) {
    paintComponent(canvas, Offset.zero & size, component);
  }

  @override
  bool shouldRepaint(_PiecePainter oldDelegate) =>
      component != oldDelegate.component;
}

/// Desenha [component] dentro de [rect]. [powered] muda o estado visual de
/// quem reage à corrente (lâmpada acesa, interruptor fechado). Compartilhado
/// entre a peça do tray e o tabuleiro (`CircuitBoard`).
void paintComponent(
  Canvas canvas,
  Rect rect,
  CircuitComponent component, {
  bool powered = false,
}) {
  switch (component) {
    case CircuitComponent.battery:
      _paintBattery(canvas, rect);
    case CircuitComponent.wire:
      _paintWire(canvas, rect);
    case CircuitComponent.bulb:
      _paintBulb(canvas, rect, lit: powered);
    case CircuitComponent.switchKey:
      _paintSwitch(canvas, rect, closed: powered);
    case CircuitComponent.resistor:
      _paintResistor(canvas, rect);
    case CircuitComponent.copper:
      _paintCopper(canvas, rect);
    case CircuitComponent.rubber:
      _paintRubber(canvas, rect);
    case CircuitComponent.wood:
      _paintWood(canvas, rect);
  }
}

const _bodyColor = Color(0xFF1F2937);
const _wireColor = Color(0xFF64748B);

Paint _stroke(Color color, double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..color = color;

/// Pilha vertical com polos + (topo) e − (base), como no `OhmCircuit`.
void _paintBattery(Canvas canvas, Rect rect) {
  final body = Rect.fromCenter(
    center: rect.center,
    width: rect.width * 0.44,
    height: rect.height * 0.86,
  );
  final rbody = RRect.fromRectAndRadius(body, Radius.circular(body.width * 0.22));
  canvas.drawRRect(rbody, Paint()..color = _bodyColor);
  canvas.drawRRect(rbody, _stroke(AppColors.electricYellow, rect.width * 0.045));

  final symbol = _stroke(AppColors.textPrimary, rect.width * 0.05);
  final arm = body.width * 0.24;
  final plus = Offset(body.center.dx, body.top + body.height * 0.22);
  canvas.drawLine(plus.translate(-arm, 0), plus.translate(arm, 0), symbol);
  canvas.drawLine(plus.translate(0, -arm), plus.translate(0, arm), symbol);
  final minus = Offset(body.center.dx, body.bottom - body.height * 0.22);
  canvas.drawLine(minus.translate(-arm, 0), minus.translate(arm, 0), symbol);
}

/// Pedaço de fio em curva suave com as pontas descascadas (conectores).
void _paintWire(Canvas canvas, Rect rect) {
  final path = Path()
    ..moveTo(rect.left + rect.width * 0.08, rect.center.dy + rect.height * 0.18)
    ..cubicTo(
      rect.left + rect.width * 0.35,
      rect.top + rect.height * 0.05,
      rect.right - rect.width * 0.35,
      rect.bottom - rect.height * 0.05,
      rect.right - rect.width * 0.08,
      rect.center.dy - rect.height * 0.18,
    );
  canvas.drawPath(path, _stroke(_wireColor, rect.width * 0.13));
  canvas.drawPath(path, _stroke(AppColors.electricCyan.withValues(alpha: 0.5), rect.width * 0.05));

  final tip = Paint()..color = AppColors.electricYellow;
  canvas.drawCircle(
    Offset(rect.left + rect.width * 0.08, rect.center.dy + rect.height * 0.18),
    rect.width * 0.06,
    tip,
  );
  canvas.drawCircle(
    Offset(rect.right - rect.width * 0.08, rect.center.dy - rect.height * 0.18),
    rect.width * 0.06,
    tip,
  );
}

/// Lâmpada: bulbo de vidro com filamento e rosca; acesa ganha brilho amarelo.
void _paintBulb(Canvas canvas, Rect rect, {required bool lit}) {
  final radius = rect.width * 0.3;
  final center = Offset(rect.center.dx, rect.top + rect.height * 0.36);

  if (lit) {
    canvas.drawCircle(
      center,
      radius * 1.65,
      Paint()
        ..color = AppColors.electricYellow.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = lit
          ? AppColors.electricYellow.withValues(alpha: 0.9)
          : _bodyColor,
  );
  canvas.drawCircle(
    center,
    radius,
    _stroke(
      lit ? AppColors.electricYellow : AppColors.electricCyan,
      rect.width * 0.04,
    ),
  );

  // Filamento em W.
  final f = _stroke(
    lit ? const Color(0xFFB45309) : AppColors.electricYellow,
    rect.width * 0.035,
  );
  final w = radius * 0.62;
  final fy = center.dy + radius * 0.12;
  final filament = Path()
    ..moveTo(center.dx - w, fy)
    ..lineTo(center.dx - w * 0.45, fy - radius * 0.42)
    ..lineTo(center.dx, fy)
    ..lineTo(center.dx + w * 0.45, fy - radius * 0.42)
    ..lineTo(center.dx + w, fy);
  canvas.drawPath(filament, f);

  // Rosca.
  final screw = Rect.fromCenter(
    center: Offset(center.dx, center.dy + radius + rect.height * 0.16),
    width: radius * 1.1,
    height: rect.height * 0.26,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(screw, Radius.circular(screw.width * 0.16)),
    Paint()..color = _wireColor,
  );
  final thread = _stroke(_bodyColor, rect.width * 0.028);
  for (var i = 1; i <= 2; i++) {
    final y = screw.top + screw.height * i / 3;
    canvas.drawLine(Offset(screw.left, y), Offset(screw.right, y), thread);
  }
}

/// Interruptor: dois contatos e a alavanca — aberta em repouso, fechada
/// quando o circuito liga.
void _paintSwitch(Canvas canvas, Rect rect, {required bool closed}) {
  final y = rect.center.dy + rect.height * 0.16;
  final a = Offset(rect.left + rect.width * 0.16, y);
  final b = Offset(rect.right - rect.width * 0.16, y);

  final base = Paint()..color = AppColors.electricYellow;
  canvas.drawCircle(a, rect.width * 0.07, base);
  canvas.drawCircle(b, rect.width * 0.07, base);

  final angle = closed ? 0.0 : -0.62;
  final length = (b - a).distance;
  final tip = a + Offset(cos(angle) * length, sin(angle) * length);
  canvas.drawLine(a, tip, _stroke(AppColors.electricCyan, rect.width * 0.06));
  canvas.drawCircle(tip, rect.width * 0.05, Paint()..color = AppColors.electricCyan);
}

/// Resistor horizontal com zigue-zague interno, como no `OhmCircuit`.
void _paintResistor(Canvas canvas, Rect rect) {
  final body = Rect.fromCenter(
    center: rect.center,
    width: rect.width * 0.9,
    height: rect.height * 0.4,
  );
  final rbody = RRect.fromRectAndRadius(body, Radius.circular(body.height * 0.3));
  canvas.drawRRect(rbody, Paint()..color = _bodyColor);
  canvas.drawRRect(rbody, _stroke(AppColors.electricCyan, rect.width * 0.035));

  final inset = body.width * 0.13;
  final zig = Path()..moveTo(body.left + inset, body.center.dy);
  const steps = 6;
  final stepW = (body.width - inset * 2) / steps;
  for (var i = 0; i < steps; i++) {
    zig.lineTo(
      body.left + inset + stepW * (i + 0.5),
      body.center.dy + (i.isEven ? -body.height * 0.24 : body.height * 0.24),
    );
  }
  zig.lineTo(body.right - inset, body.center.dy);
  canvas.drawPath(zig, _stroke(AppColors.electricYellow, rect.width * 0.035));
}

const _copperColor = Color(0xFFD97706);

/// Barra de cobre com espiras enroladas (o condutor da quest 4).
void _paintCopper(Canvas canvas, Rect rect) {
  final bar = Rect.fromCenter(
    center: rect.center,
    width: rect.width * 0.86,
    height: rect.height * 0.34,
  );
  final rbar = RRect.fromRectAndRadius(bar, Radius.circular(bar.height * 0.5));
  canvas.drawRRect(rbar, Paint()..color = _copperColor);
  canvas.drawRRect(rbar, _stroke(const Color(0xFF92400E), rect.width * 0.03));

  final coil = _stroke(const Color(0xFFFBBF24), rect.width * 0.035);
  const turns = 4;
  for (var i = 1; i <= turns; i++) {
    final x = bar.left + bar.width * i / (turns + 1);
    canvas.drawLine(
      Offset(x - bar.height * 0.28, bar.bottom),
      Offset(x + bar.height * 0.28, bar.top),
      coil,
    );
  }
}

/// Borracha escolar (isolante): corpo rosa com cinta escura.
void _paintRubber(Canvas canvas, Rect rect) {
  final body = Rect.fromCenter(
    center: rect.center,
    width: rect.width * 0.78,
    height: rect.height * 0.44,
  );
  final rbody = RRect.fromRectAndRadius(body, Radius.circular(body.height * 0.28));
  canvas.drawRRect(rbody, Paint()..color = const Color(0xFFF472B6));
  canvas.drawRRect(rbody, _stroke(const Color(0xFFBE185D), rect.width * 0.03));

  final band = Rect.fromLTWH(body.left, body.top, body.width * 0.34, body.height);
  canvas.save();
  canvas.clipRRect(rbody);
  canvas.drawRect(band, Paint()..color = const Color(0xFF334155));
  canvas.restore();
}

/// Palito de madeira (isolante): bastão marrom com veios.
void _paintWood(Canvas canvas, Rect rect) {
  final body = Rect.fromCenter(
    center: rect.center,
    width: rect.width * 0.88,
    height: rect.height * 0.3,
  );
  final rbody = RRect.fromRectAndRadius(body, Radius.circular(body.height * 0.5));
  canvas.drawRRect(rbody, Paint()..color = const Color(0xFF92400E));
  canvas.drawRRect(rbody, _stroke(const Color(0xFF78350F), rect.width * 0.03));

  final grain = _stroke(const Color(0xFF78350F), rect.width * 0.022);
  for (var i = 1; i <= 3; i++) {
    final y = body.top + body.height * i / 4;
    canvas.drawLine(
      Offset(body.left + body.width * 0.12, y),
      Offset(body.right - body.width * 0.12, y),
      grain,
    );
  }
}
