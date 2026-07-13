import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../core/app_assets.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/game_background.dart';

/// Tela de carregamento entre fases: fundo padrão + animação Lottie em loop.
///
/// Uso típico na navegação (quando o `AppRouter` entrar): empurrar esta tela,
/// aguardar o [minDuration] e o preparo da próxima fase (precache de sprites,
/// áudio etc.) e então trocar pela fase via `pushReplacement`. [onFinished] é
/// chamado ao fim do [minDuration] — sem ele a tela fica em loop (útil
/// enquanto quem chama controla a troca por fora).
class PhaseLoadingScreen extends StatefulWidget {
  const PhaseLoadingScreen({
    super.key,
    this.message = 'Carregando...',
    this.minDuration,
    this.onFinished,
  });

  /// Texto exibido sob a animação.
  final String message;

  /// Tempo mínimo em tela antes de disparar [onFinished].
  final Duration? minDuration;

  /// Chamado uma única vez após [minDuration].
  final VoidCallback? onFinished;

  @override
  State<PhaseLoadingScreen> createState() => _PhaseLoadingScreenState();
}

class _PhaseLoadingScreenState extends State<PhaseLoadingScreen> {
  @override
  void initState() {
    super.initState();
    final min = widget.minDuration;
    if (min != null && widget.onFinished != null) {
      Future.delayed(min, () {
        if (mounted) widget.onFinished!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                AppAssets.loadingPhaseLottie,
                width: 160.r,
                height: 160.r,
                // Em testes/erro de decode não derruba a tela; fica só o texto.
                errorBuilder: (_, __, ___) => SizedBox(width: 160.r, height: 160.r),
              ),
              SizedBox(height: 8.r),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}