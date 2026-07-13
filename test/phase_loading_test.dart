import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:startenergy/core/widgets/game_background.dart';
import 'package:startenergy/features/loading/phase_loading_screen.dart';

import 'test_app.dart';

void main() {
  testWidgets('tela de loading monta fundo, animação e mensagem', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const PhaseLoadingScreen()));
    await tester.pump();

    expect(find.byType(GameBackground), findsOneWidget);
    expect(find.byType(LottieBuilder), findsOneWidget);
    expect(find.text('Carregando...'), findsOneWidget);
  });

  testWidgets('onFinished dispara após o minDuration', (tester) async {
    var finished = false;
    await tester.pumpWidget(
      testApp(
        PhaseLoadingScreen(
          minDuration: const Duration(milliseconds: 300),
          onFinished: () => finished = true,
        ),
      ),
    );
    await tester.pump();
    expect(finished, isFalse);

    await tester.pump(const Duration(milliseconds: 400));
    expect(finished, isTrue);
  });
}
