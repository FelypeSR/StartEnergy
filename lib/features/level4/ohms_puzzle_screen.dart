import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';

class OhmsPuzzleScreen extends StatefulWidget {
  const OhmsPuzzleScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<OhmsPuzzleScreen> createState() => _OhmsPuzzleScreenState();
}

class _OhmsPuzzleScreenState extends State<OhmsPuzzleScreen> {
  // Puzzle configuration
  final int targetCurrent = 2; // Amperes
  final int resistance = 5; // Ohms
  final int correctVoltage = 10; // Volts (V = R * I)

  final List<int> batteryOptions = [5, 10, 20]; // Volts

  int? _placedVoltage;
  bool _isWrong = false;

  bool get _isSolved => _placedVoltage == correctVoltage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
            child: Column(
              children: [
                Text(
                  'Fase 4: Desafio Lei de Ohm',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.electricYellow,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'Arraste a Bateria (Volts) correta usando a Lei de Ohm (V = R × I).',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.r),
                // Máquina com o DragTarget (Flexível)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTop.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _isSolved ? AppColors.electricYellow : AppColors.electricCyan, 
                        width: 3,
                      ),
                      boxShadow: _isSolved ? [
                        BoxShadow(
                          color: AppColors.electricYellow.withValues(alpha: 0.6),
                          blurRadius: 20.r,
                          spreadRadius: 4.r,
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Motor Principal',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.r),
                        Text(
                          'Corrente Necessária: ${targetCurrent}A',
                          style: TextStyle(fontSize: 18.sp, color: AppColors.electricYellow),
                        ),
                        Text(
                          'Resistência do Motor: ${resistance}Ω',
                          style: TextStyle(fontSize: 18.sp, color: Colors.orangeAccent),
                        ),
                        SizedBox(height: 16.r),
                        DragTarget<int>(
                          builder: (context, candidateData, rejectedData) {
                            final isHovered = candidateData.isNotEmpty;
                            
                            if (_placedVoltage != null) {
                              return Container(
                                width: 80.r,
                                height: 80.r,
                                decoration: BoxDecoration(
                                  color: _isWrong ? Colors.redAccent.withValues(alpha: 0.2) : AppColors.backgroundTop,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: _isWrong ? Colors.redAccent : Colors.greenAccent, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '${_placedVoltage}V',
                                    style: TextStyle(
                                      fontSize: 24.sp, 
                                      fontWeight: FontWeight.bold, 
                                      color: _isWrong ? Colors.redAccent : Colors.greenAccent,
                                    ),
                                  ),
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
                                Icons.battery_charging_full_rounded,
                                size: 32.r,
                                color: AppColors.textMuted.withValues(alpha: 0.5),
                              ),
                            );
                          },
                          onWillAcceptWithDetails: (details) => _placedVoltage == null,
                          onAcceptWithDetails: (details) {
                            setState(() {
                              _placedVoltage = details.data;
                              if (_placedVoltage != correctVoltage) {
                                _isWrong = true;
                                // Reseta a bateria após curto circuito
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (mounted) {
                                    setState(() {
                                      _placedVoltage = null;
                                      _isWrong = false;
                                    });
                                  }
                                });
                              } else {
                                _isWrong = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.r),
                // Opções de baterias (em linha responsiva)
                Wrap(
                  spacing: 16.r,
                  runSpacing: 16.r,
                  alignment: WrapAlignment.center,
                  children: batteryOptions.map((volts) {
                    final isPlaced = _placedVoltage == volts;
                    if (isPlaced) return SizedBox(height: 80.r, width: 80.r);
                    return _DraggableBattery(volts: volts);
                  }).toList(),
                ),
                SizedBox(height: 16.r),
                if (_isSolved)
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

class _DraggableBattery extends StatelessWidget {
  const _DraggableBattery({required this.volts});

  final int volts;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 80.r,
      height: 80.r,
      decoration: BoxDecoration(
        color: AppColors.backgroundTop,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.greenAccent, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.battery_charging_full_rounded, size: 32.r, color: Colors.greenAccent),
          SizedBox(height: 2.r),
          Text(
            '${volts}V',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );

    return Draggable<int>(
      data: volts,
      feedback: Opacity(opacity: 0.8, child: child),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }
}
