import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/level1/quiz_models.dart';
import '../app_colors.dart';
import 'sound_button.dart';

/// Resultado de fim de fase: 1–3 estrelas ([starsForCorrect]) surgindo com
/// bounce escalonado, uma linha de placar e o botão Continuar.
///
/// Usado pelo quiz (levels 1 e 2) e pelo drag & drop (level 3).
class PhaseResult extends StatefulWidget {
  const PhaseResult({
    super.key,
    required this.title,
    required this.scoreText,
    required this.correct,
    required this.total,
    required this.onContinue,
  });

  final String title;

  /// Linha de placar exibida sob as estrelas (ex.: "Você acertou 4 de 5!").
  final String scoreText;

  /// Acertos e total, convertidos em estrelas por [starsForCorrect].
  final int correct;
  final int total;

  final VoidCallback onContinue;

  @override
  State<PhaseResult> createState() => _PhaseResultState();
}

class _PhaseResultState extends State<PhaseResult>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stars = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void dispose() {
    _stars.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earned = starsForCorrect(widget.correct, widget.total);
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 20.r),
        decoration: BoxDecoration(
          color: AppColors.backgroundTop.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.electricCyan.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.r),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _stars,
                      curve: Interval(
                        i * 0.22,
                        i * 0.22 + 0.34,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Icon(
                      i < earned
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 52.r,
                      color: i < earned
                          ? AppColors.electricYellow
                          : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.r),
            Text(
              widget.scoreText,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 16.r),
            SoundButton(
              label: 'Continuar',
              width: 220.r,
              onPressed: widget.onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
