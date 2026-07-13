import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_colors.dart';
import 'ohm_circuit.dart';

/// Laboratório da Lei de Ohm: readout da fórmula ao vivo, circuito animado
/// ([OhmCircuit]) e as duas barras de grandeza — tensão (V) e resistência
/// (R). Arrastar as barras recalcula I = V ÷ R e a velocidade do fluxo de
/// elétrons no circuito acompanha a corrente.
class FormulaCard extends StatefulWidget {
  const FormulaCard({super.key});

  @override
  State<FormulaCard> createState() => _FormulaCardState();
}

class _FormulaCardState extends State<FormulaCard> {
  double _volts = 6;
  double _ohms = 3;

  double get _amps => _volts / _ohms;

  static String _fmt(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.r, 14.r, 18.r, 8.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundTop.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.electricCyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: Colors.amber, size: 26.r),
              SizedBox(width: 6.r),
              Text(
                'Lei de Ohm',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 12.r),
              // Encolhe o readout em telas estreitas em vez de estourar.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_fmt(_volts)} V ÷ ${_fmt(_ohms)} Ω',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(width: 10.r),
                      Text(
                        'I = ${_fmt(_amps)} A',
                        key: const ValueKey('current-readout'),
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.electricYellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: OhmCircuit(current: _amps)),
          _GaugeRow(
            simbolo: 'V',
            unidade: 'V',
            value: _volts,
            min: 0,
            max: 12,
            divisions: 24,
            color: AppColors.electricYellow,
            onChanged: (v) => setState(() => _volts = v),
          ),
          _GaugeRow(
            simbolo: 'R',
            unidade: 'Ω',
            value: _ohms,
            min: 1,
            max: 12,
            divisions: 22,
            color: AppColors.electricCyan,
            onChanged: (v) => setState(() => _ohms = v),
          ),
        ],
      ),
    );
  }
}

/// Linha de uma grandeza: avatar do símbolo, barra deslizante e o valor.
class _GaugeRow extends StatelessWidget {
  const _GaugeRow({
    required this.simbolo,
    required this.unidade,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.onChanged,
  });

  final String simbolo;
  final String unidade;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 13.r,
          backgroundColor: AppColors.menuBlue,
          child: Text(
            simbolo,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 52.r,
          child: Text(
            '${_FormulaCardState._fmt(value)} $unidade',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
