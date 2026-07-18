import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startenergy/core/widgets/sheet_sprite.dart';
import 'package:startenergy/core/widgets/speech_balloon.dart';
import 'package:startenergy/features/cutscene/cutscene_screen.dart';
import 'package:startenergy/features/cutscene/cutscene_script.dart';
import 'package:startenergy/features/level3/circuit_models.dart';
import 'package:startenergy/features/level3/dragdrop_screen.dart';
import 'package:startenergy/features/menu/menu_screen.dart';
import 'package:startenergy/features/splash/splash_screen.dart';
import 'package:startenergy/features/tutorial/tutorial_prompt.dart';
import 'package:startenergy/features/tutorial/tutorial_screen.dart';

import 'test_app.dart';

/// Regressão de telas pequenas (landscape): o layout deve caber sem rolagem,
/// sobreposição ou corte da menor tela suportada até a referência de design.
const sizes = [
  Size(568, 320), // muito pequeno (ex.: Android compacto antigo)
  Size(640, 360), // pequeno 16:9 clássico, o landscape mais comum
  Size(732, 412), // referência de design
];

void main() {
  for (final size in sizes) {
    group('${size.width.toInt()}x${size.height.toInt()}', () {
      Future<void> setSize(WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }

      testWidgets('menu cabe inteiro, sem rolagem', (tester) async {
        await setSize(tester);
        await tester.pumpWidget(testApp(const MenuScreen()));
        await tester.pump();

        final position =
            tester.state<ScrollableState>(find.byType(Scrollable)).position;
        expect(position.maxScrollExtent, 0,
            reason: 'a coluna do menu não deve precisar rolar');
        expect(tester.takeException(), isNull);
      });

      testWidgets('splash: logo não invade o "toque para continuar"',
          (tester) async {
        await setSize(tester);
        await tester.pumpWidget(testApp(const SplashScreen()));
        await tester.pump(const Duration(milliseconds: 900));

        final subtitle = tester.getRect(
          find.text('Aprenda eletricidade jogando'),
        );
        final hint = tester.getRect(find.text('Toque para continuar'));
        expect(subtitle.bottom, lessThan(hint.top),
            reason: 'subtítulo do logo deve terminar acima da dica de toque');
        expect(tester.takeException(), isNull);
      });

      testWidgets('cutscene: balão não cobre o personagem', (tester) async {
        await setSize(tester);
        // Usa a fala mais longa do roteiro real: é o pior caso de altura do balão.
        final longest = introCutscene
            .reduce((a, b) => a.text.length >= b.text.length ? a : b);
        await tester.pumpWidget(
          testApp(CutsceneScreen(frames: [longest], onFinished: () {})),
        );
        // Decodifica o sprite de verdade (async real, fora do tempo fake).
        await tester.runAsync(() => precacheImage(
              AssetImage(longest.characterSprite),
              tester.element(find.byType(CutsceneScreen)),
            ));
        await tester.pumpAndSettle(); // conclui a digitação da fala

        final balloon = tester.getRect(find.byType(SpeechBalloon));
        final sprite = tester.getRect(find.byType(SheetSprite));
        expect(sprite.width, greaterThan(0),
            reason: 'o sprite deve ter decodificado no teste');
        final horizontalOverlap =
            balloon.right > sprite.left && balloon.left < sprite.right;
        if (horizontalOverlap) {
          expect(balloon.bottom, lessThanOrEqualTo(sprite.top),
              reason: 'o balão deve terminar acima da cabeça do personagem');
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets('tutorial: painel, cartas e balão cabem', (tester) async {
        await setSize(tester);
        await tester.pumpWidget(
          testApp(
            TutorialScreen(
              introFrames: const [], // direto na fase das cartas
              random: Random(3),
              onFinished: () {},
            ),
          ),
        );
        await tester.pumpAndSettle(); // queda das cartas + digitação

        for (final p in Particle.values) {
          final rect = tester.getRect(find.byKey(ValueKey(p)));
          expect(rect.bottom, lessThanOrEqualTo(size.height),
              reason: 'carta deve pousar dentro da tela');
          expect(rect.top, greaterThanOrEqualTo(0));
        }
        final balloon = tester.getRect(find.byType(SpeechBalloon));
        expect(balloon.right, lessThanOrEqualTo(size.width));
        expect(tester.takeException(), isNull);
      });

      testWidgets('drag & drop: tabuleiro, tray e balão cabem',
          (tester) async {
        await setSize(tester);
        await tester.pumpWidget(
          testApp(DragDropScreen(random: Random(3), onFinished: (_) {})),
        );
        await tester.pump();

        for (final side in [SlotSide.left, SlotSide.top, SlotSide.right]) {
          final rect =
              tester.getRect(find.byKey(ValueKey('slot-${side.name}')));
          expect(rect.bottom, lessThanOrEqualTo(size.height),
              reason: 'lacuna deve caber na tela');
          expect(rect.top, greaterThanOrEqualTo(0));
        }
        final tray = tester.getRect(find.byKey(const ValueKey('tray-bulb')));
        expect(tray.bottom, lessThanOrEqualTo(size.height));
        final balloon = tester.getRect(find.byType(SpeechBalloon));
        expect(balloon.right, lessThanOrEqualTo(size.width));
        expect(tester.takeException(), isNull);
      });
    });
  }
}