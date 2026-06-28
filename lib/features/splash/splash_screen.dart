import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/brand_wordmark.dart';
import '../../core/widgets/game_background.dart';

/// Tela inicial do StartEnergy (landscape).
///
/// Apresenta a marca e aguarda o toque do jogador para iniciar.
/// Toda a área é tocável para um alvo de toque generoso.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onContinue});

  /// Disparado quando o jogador toca a tela para continuar.
  final VoidCallback? onContinue;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _contentFade;

  bool _continuing = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _logoScale = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_continuing) return;
    setState(() => _continuing = true);
    widget.onContinue?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: GameBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const _Logo(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: _TapToContinue(animation: _pulseController),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0x33FFD60A), Colors.transparent],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricYellow.withValues(alpha: 0.35),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt,
            size: 84,
            color: AppColors.electricYellow,
          ),
        ),
        const SizedBox(height: 16),
        const BrandWordmark(),
        const SizedBox(height: 8),
        Text(
          'Aprenda eletricidade jogando',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _TapToContinue extends StatelessWidget {
  const _TapToContinue({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(animation),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 22,
            color: AppColors.electricCyan,
          ),
          const SizedBox(width: 10),
          Text(
            'Toque para continuar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
