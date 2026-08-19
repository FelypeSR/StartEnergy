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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.r),
              child: Container(
                width: 500.w,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.backgroundBottom.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.electricYellow.withValues(alpha: 0.5),
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
                    const _CreditEntry(
                      role: 'Desenvolvimento',
                      name: 'Felipe Santos',
                      github: '@FelypeSR',
                    ),
                    SizedBox(height: 20.r),
                    const _CreditEntry(
                      role: 'Colaboração',
                      name: 'Lara Emanuelly',
                      github: '@LaraEmanuelly',
                    ),
                    SizedBox(height: 24.r),
                    Text(
                      'StartEnergy\n\nDesenvolvido para ensinar conceitos de eletricidade de forma interativa e divertida.',
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
      ),
    );
  }
}

class _CreditEntry extends StatelessWidget {
  const _CreditEntry({
    required this.role,
    required this.name,
    required this.github,
  });

  final String role;
  final String name;
  final String github;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          role.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.electricCyan,
          ),
        ),
        SizedBox(height: 4.r),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2.r),
        Text(
          github,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
