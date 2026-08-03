import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';

class CircuitScreen extends StatefulWidget {
  const CircuitScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<CircuitScreen> createState() => _CircuitScreenState();
}

class _CircuitScreenState extends State<CircuitScreen> {
  bool _batteryPlaced = false;
  bool _switchPlaced = false;
  bool _bulbPlaced = false;

  bool _switchOn = false;

  bool get _allComponentsPlaced => _batteryPlaced && _switchPlaced && _bulbPlaced;
  bool get _isCircuitComplete => _allComponentsPlaced && _switchOn;

  @override
  Widget build(BuildContext context) {
    final wireColor = _isCircuitComplete 
        ? AppColors.electricYellow 
        : AppColors.textMuted.withValues(alpha: 0.5);

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
            child: Column(
              children: [
                Text(
                  'Fase 3: Monte o Circuito',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.electricYellow,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'Arraste as peças para o circuito e pressione a chave para ligar!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.r),
                // Placa do Circuito (Simples e Responsiva usando Row)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTop.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.electricCyan, width: 2),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Bateria
                          _Slot(
                            acceptedData: 'battery',
                            isFilled: _batteryPlaced,
                            filledIcon: Icons.battery_charging_full_rounded,
                            filledColor: Colors.greenAccent,
                            onAccept: () => setState(() => _batteryPlaced = true),
                          ),
                          // Fio
                          Container(width: 40.r, height: 6.r, color: wireColor),
                          // Chave
                          _Slot(
                            acceptedData: 'switch',
                            isFilled: _switchPlaced,
                            filledIcon: _switchOn ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                            filledColor: _switchOn ? AppColors.electricYellow : Colors.blueAccent,
                            onAccept: () => setState(() => _switchPlaced = true),
                            onTap: _switchPlaced ? () {
                              setState(() {
                                _switchOn = !_switchOn;
                              });
                            } : null,
                          ),
                          // Fio
                          Container(width: 40.r, height: 6.r, color: wireColor),
                          // Lâmpada
                          _Slot(
                            acceptedData: 'bulb',
                            isFilled: _bulbPlaced,
                            filledIcon: _isCircuitComplete 
                                ? Icons.lightbulb_rounded 
                                : Icons.lightbulb_outline_rounded,
                            filledColor: _isCircuitComplete 
                                ? AppColors.electricYellow 
                                : Colors.orangeAccent,
                            onAccept: () => setState(() => _bulbPlaced = true),
                            glow: _isCircuitComplete,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.r),
                // Peças para arrastar
                Wrap(
                  spacing: 16.r,
                  runSpacing: 16.r,
                  alignment: WrapAlignment.center,
                  children: [
                    if (!_batteryPlaced)
                      _DraggableItem(
                        data: 'battery',
                        icon: Icons.battery_charging_full_rounded,
                        color: Colors.greenAccent,
                        label: 'Bateria',
                      )
                    else
                      SizedBox(width: 80.r, height: 80.r),
                    if (!_switchPlaced)
                      _DraggableItem(
                        data: 'switch',
                        icon: Icons.toggle_off_rounded,
                        color: Colors.blueAccent,
                        label: 'Chave',
                      )
                    else
                      SizedBox(width: 80.r, height: 80.r),
                    if (!_bulbPlaced)
                      _DraggableItem(
                        data: 'bulb',
                        icon: Icons.lightbulb_outline_rounded,
                        color: Colors.orangeAccent,
                        label: 'Lâmpada',
                      )
                    else
                      SizedBox(width: 80.r, height: 80.r),
                  ],
                ),
                SizedBox(height: 16.r),
                if (_isCircuitComplete)
                  SoundButton(
                    label: 'Concluir',
                    icon: Icons.check_circle_outline_rounded,
                    primary: true,
                    onPressed: () {
                      widget.onFinished?.call();
                    },
                  )
                else
                  SoundButton(
                    label: 'Voltar',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggableItem extends StatelessWidget {
  const _DraggableItem({
    required this.data,
    required this.icon,
    required this.color,
    required this.label,
  });

  final String data;
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 80.r,
      height: 80.r,
      decoration: BoxDecoration(
        color: AppColors.backgroundTop,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36.r, color: color),
          SizedBox(height: 2.r),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textPrimary),
          ),
        ],
      ),
    );

    return Draggable<String>(
      data: data,
      feedback: Opacity(opacity: 0.8, child: child),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.acceptedData,
    required this.isFilled,
    required this.filledIcon,
    required this.filledColor,
    required this.onAccept,
    this.glow = false,
    this.onTap,
  });

  final String acceptedData;
  final bool isFilled;
  final IconData filledIcon;
  final Color filledColor;
  final VoidCallback onAccept;
  final bool glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        
        if (isFilled) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: AppColors.backgroundTop,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: filledColor, width: 2),
                boxShadow: glow ? [
                  BoxShadow(
                    color: filledColor.withValues(alpha: 0.6),
                    blurRadius: 15.r,
                    spreadRadius: 2.r,
                  )
                ] : null,
              ),
              child: Icon(filledIcon, size: 42.r, color: filledColor),
            ),
          );
        }

        return Container(
          width: 80.r,
          height: 80.r,
          decoration: BoxDecoration(
            color: isHovered ? AppColors.backgroundTop.withValues(alpha: 0.8) : AppColors.backgroundTop.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isHovered ? AppColors.electricYellow : AppColors.textMuted.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.add_rounded,
            size: 32.r,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
        );
      },
      onWillAcceptWithDetails: (details) => details.data == acceptedData,
      onAcceptWithDetails: (details) => onAccept(),
    );
  }
}
