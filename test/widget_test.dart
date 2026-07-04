import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:startenergy/core/audio_controller.dart';
import 'package:startenergy/core/widgets/sound_button.dart';
import 'package:startenergy/core/widgets/sound_toggle_button.dart';
import 'package:startenergy/features/menu/menu_screen.dart';
import 'package:startenergy/features/splash/splash_screen.dart';

import 'test_app.dart';

void main() {
  testWidgets('Splash mostra marca e chamada de toque', (tester) async {
    await tester.pumpWidget(testApp(const SplashScreen()));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Toque para continuar'), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });

  testWidgets('Toque dispara onContinue', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      testApp(SplashScreen(onContinue: () => tapped = true)),
    );

    await tester.tap(find.byType(SplashScreen));
    expect(tapped, isTrue);
  });

  testWidgets('Menu mostra JOGAR e o botão de som', (tester) async {
    await tester.pumpWidget(testApp(const MenuScreen()));

    expect(find.text('JOGAR'), findsOneWidget);
    expect(find.byType(SoundToggleButton), findsOneWidget);
  });

  testWidgets('SoundButton dispara onPressed ao tocar', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: SoundButton(
            label: 'OK',
            icon: Icons.check,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SoundButton));
    await tester.pump();
    expect(pressed, isTrue);
  });

  testWidgets('Botão de som alterna o estado do áudio', (tester) async {
    final controller = AudioController.instance;
    final inicial = controller.enabled;

    await tester.pumpWidget(
      testApp(const Scaffold(body: SoundToggleButton())),
    );

    await tester.tap(find.byType(SoundToggleButton));
    await tester.pump();
    expect(controller.enabled, !inicial);

    // Restaura o estado global para não afetar outros testes.
    await controller.setEnabled(inicial);
  });
}
