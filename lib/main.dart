import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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

  // Mantém a tela acesa durante o jogo inteiro: cutscenes e questões deixam o
  // jogador tempos longos sem tocar na tela e o timeout do aparelho apagaria.
  await WakelockPlus.enable();

  runApp(StartEnergyApp());
}

class StartEnergyApp extends StatelessWidget {
  StartEnergyApp({super.key});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Resolução de referência do design (landscape 16:9, 412dp de altura).
  ///
  /// Com a referência no aspecto 16:9, `.r`/`.sp` seguem a escala da ALTURA em
  /// qualquer celular (que é sempre 16:9 ou mais largo em landscape): telas
  /// com 412dp+ de altura ficam com o layout em tamanho pleno e telas menores
  /// encolhem proporcionalmente — sem tarjas e sempre em resolução nativa.
  static const Size designSize = Size(732, 412);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
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
      ),
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
