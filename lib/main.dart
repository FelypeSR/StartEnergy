import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_colors.dart';
import 'core/audio_controller.dart';
import 'features/menu/menu_screen.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // O jogo é exclusivamente landscape.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Experiência imersiva (esconde barras de status/navegação).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(StartEnergyApp());
}

class StartEnergyApp extends StatelessWidget {
  StartEnergyApp({super.key});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StartEnergy',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundTop,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.electricYellow,
          brightness: Brightness.dark,
        ),
      ),
      home: SplashScreen(onContinue: _startGame),
    );
  }

  /// Inicia a música (primeiro gesto do usuário libera o autoplay no navegador)
  /// e abre o menu. Navegação temporária até existir um AppRouter.
  void _startGame() {
    AudioController.instance.start();
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => const MenuScreen()),
    );
  }
}
