import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Center(
            child: Container(
              width: 500.w,
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundBottom.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.electricYellow.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Créditos',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.electricYellow,
                    ),
                  ),
                  SizedBox(height: 24.r),
                  Text(
                    'StartEnergy\n\nDesenvolvido para ensinar conceitos de eletricidade de forma interativa e divertida.\n\nAgradecimentos especiais a todos que testaram e colaboraram com o projeto!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.r),
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
