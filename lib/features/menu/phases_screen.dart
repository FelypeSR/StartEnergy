import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/brand_wordmark.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';

class PhasesScreen extends StatelessWidget {
  const PhasesScreen({
    super.key,
    required this.onPlayTutorial,
    required this.onPlayPhase1,
    required this.onPlayPhase2,
    required this.onPlayLeiDeOhm,
    required this.onPlayCircuit,
    required this.onPlayOhmsPuzzle,
  });

  final VoidCallback onPlayTutorial;
  final VoidCallback onPlayPhase1;
  final VoidCallback onPlayPhase2;
  final VoidCallback onPlayLeiDeOhm;
  final VoidCallback onPlayCircuit;
  final VoidCallback onPlayOhmsPuzzle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Fases do Jogo',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.electricYellow,
                    ),
                  ),
                  SizedBox(height: 28.r),
                  SoundButton(
                    label: 'Tutorial',
                    icon: Icons.school_rounded,
                    onPressed: onPlayTutorial,
                  ),
                  SizedBox(height: 14.r),
                  SoundButton(
                    label: 'Fase 1 (Quiz)',
                    icon: Icons.looks_one_rounded,
                    onPressed: onPlayPhase1,
                  ),
                  SizedBox(height: 14.r),
                  SoundButton(
                    label: 'Fase 2 (Quiz)',
                    icon: Icons.looks_two_rounded,
                    onPressed: onPlayPhase2,
                  ),
                  SizedBox(height: 14.r),
                  SoundButton(
                    label: 'Lei de Ohm',
                    icon: Icons.electric_bolt_rounded,
                    onPressed: onPlayLeiDeOhm,
                  ),
                  SizedBox(height: 14.r),
                  SoundButton(
                    label: 'Montar Circuito',
                    icon: Icons.electrical_services_rounded,
                    onPressed: onPlayCircuit,
                  ),
                  SizedBox(height: 14.r),
                  SoundButton(
                    label: 'Desafio Lei de Ohm',
                    icon: Icons.calculate_rounded,
                    onPressed: onPlayOhmsPuzzle,
                  ),
                  SizedBox(height: 28.r),
                  SoundButton(
                    label: 'Voltar',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
