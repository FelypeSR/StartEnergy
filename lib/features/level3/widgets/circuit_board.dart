import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_colors.dart';
import '../circuit_models.dart';
import 'component_piece.dart';

/// Tabuleiro da quest: o laço de fio é desenhado com lacunas nos lados ainda
/// vazios; cada lacuna é um `DragTarget` com a silhueta da peça esperada.
/// Peça certa preenche o slot; peça errada balança a lacuna (o snap-back de
/// volta ao tray é do próprio `Draggable`). Com todas preenchidas e
/// [powered], os elétrons fluem pelo laço (padrão do `OhmCircuit`: Ticker +
/// `ValueNotifier` como `repaint` — o Ticker SÓ roda enquanto ligado).
class CircuitBoard extends StatefulWidget {
  const CircuitBoard({
    super.key,
    required this.quest,
    required this.placed,
    required this.powered,
    required this.onCorrectDrop,
    required this.onWrongDrop,
  });

  final CircuitQuest quest;

  /// Peças já encaixadas, por lado do laço.
  final Map<SlotSide, CircuitComponent> placed;

  final bool powered;

  final ValueChanged<CircuitSlot> onCorrectDrop;
  final ValueChanged<CircuitSlot> onWrongDrop;

  @override
  State<CircuitBoard> createState() => _CircuitBoardState();
}

class _CircuitBoardState extends State<CircuitBoard>
    with TickerProviderStateMixin {
  final ValueNotifier<double> _phase = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  SlotSide? _shakingSide;

  @override
  void initState() {
    super.initState();
    if (widget.powered) _startFlow();
  }

  @override
  void didUpdateWidget(CircuitBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.powered && !_ticker.isActive) _startFlow();
    if (!widget.powered && _ticker.isActive) _ticker.stop();
  }

  void _startFlow() {
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _phase.value = (_phase.value + dt * 0.22) % 1.0;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shake.dispose();
    _phase.dispose();
    super.dispose();
  }

  void _handleDrop(CircuitSlot slot, CircuitComponent piece) {
    if (piece == slot.expected) {
      widget.onCorrectDrop(slot);
      return;
    }
    setState(() => _shakingSide = slot.side);
    _shake.forward(from: 0);
    widget.onWrongDrop(slot);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final geometry = BoardGeometry(size, slotSize: 62.r);
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BoardPainter(
                  quest: widget.quest,
                  placed: Map.of(widget.placed),
                  powered: widget.powered,
                  phase: _phase,
                  geometry: geometry,
                ),
              ),
            ),
            for (final slot in widget.quest.slots)
              if (!widget.placed.containsKey(slot.side))
                Positioned.fromRect(
                  rect: geometry.slotRect(slot.side),
                  child: AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) {
                      final wiggle = _shakingSide == slot.side
                          ? sin(_shake.value * pi * 5) *
                              6.r *
                              (1 - _shake.value)
                          : 0.0;
                      return Transform.translate(
                        offset: Offset(wiggle, 0),
                        child: child,
                      );
                    },
                    child: _SlotTarget(
                      key: ValueKey('slot-${slot.side.name}'),
                      slot: slot,
                      enabled: !widget.powered,
                      onDrop: (piece) => _handleDrop(slot, piece),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

/// Lacuna vazia: silhueta da peça esperada + rótulo, borda que acende quando
/// uma peça paira por cima.
class _SlotTarget extends StatelessWidget {
  const _SlotTarget({
    super.key,
    required this.slot,
    required this.enabled,
    required this.onDrop,
  });

  final CircuitSlot slot;
  final bool enabled;
  final ValueChanged<CircuitComponent> onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<CircuitComponent>(
      onWillAcceptWithDetails: (_) => enabled,
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundTop.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: hovering
                  ? AppColors.electricYellow
                  : AppColors.electricCyan.withValues(alpha: 0.55),
              width: hovering ? 2.4 : 1.6,
            ),
          ),
          padding: EdgeInsets.all(5.r),
          child: Opacity(
            opacity: 0.4,
            // FittedBox: a silhueta (arte + rótulo) nunca estoura o slot.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ComponentPiece(
                component: slot.expected,
                size: 34.r,
                showLabel: true,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Geometria compartilhada entre o painter e os `DragTarget`s: o retângulo do
/// laço e o quadrado de cada lacuna, centrado no lado correspondente.
class BoardGeometry {
  BoardGeometry(Size size, {required this.slotSize})
      : loopRect = Rect.fromLTRB(
          slotSize * 0.68,
          slotSize * 0.68,
          size.width - slotSize * 0.68,
          size.height - slotSize * 0.68,
        );

  final double slotSize;
  final Rect loopRect;

  Rect slotRect(SlotSide side) {
    final center = switch (side) {
      SlotSide.left => Offset(loopRect.left, loopRect.center.dy),
      SlotSide.top => Offset(loopRect.center.dx, loopRect.top),
      SlotSide.right => Offset(loopRect.right, loopRect.center.dy),
      SlotSide.bottom => Offset(loopRect.center.dx, loopRect.bottom),
    };
    return Rect.fromCenter(center: center, width: slotSize, height: slotSize);
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.quest,
    required this.placed,
    required this.powered,
    required this.phase,
    required this.geometry,
  }) : super(repaint: phase);

  final CircuitQuest quest;
  final Map<SlotSide, CircuitComponent> placed;
  final bool powered;
  final ValueListenable<double> phase;
  final BoardGeometry geometry;

  static const int _electronCount = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = geometry.loopRect;
    if (rect.isEmpty) return;
    final loop = RRect.fromRectAndRadius(rect, Radius.circular(16.r));

    // Fio do laço, com o trecho apagado nas lacunas ainda vazias.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRRect(
      loop,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF64748B),
    );
    final hole = Paint()..blendMode = BlendMode.clear;
    for (final slot in quest.slots) {
      if (!placed.containsKey(slot.side)) {
        canvas.drawRect(geometry.slotRect(slot.side).inflate(2), hole);
      }
    }
    canvas.restore();

    if (powered) {
      final metric = (Path()..addRRect(loop)).computeMetrics().first;
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
    }

    for (final slot in quest.slots) {
      final piece = placed[slot.side];
      if (piece != null) {
        paintComponent(
          canvas,
          geometry.slotRect(slot.side).deflate(4),
          piece,
          powered: powered,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BoardPainter oldDelegate) =>
      quest != oldDelegate.quest ||
      powered != oldDelegate.powered ||
      !mapEquals(placed, oldDelegate.placed) ||
      phase != oldDelegate.phase;
}
