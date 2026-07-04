import '../../core/app_assets.dart';

/// Partículas do quiz de cartas (tutorial e level 1).
enum Particle { proton, eletron, neutron }

extension ParticleCard on Particle {
  /// Asset da carta correspondente à partícula.
  String get cardAsset => switch (this) {
        Particle.proton => AppAssets.protonCard,
        Particle.eletron => AppAssets.eletronCard,
        Particle.neutron => AppAssets.neutronCard,
      };
}

/// Uma dica numerada do painel e a carta que a responde.
///
/// A ordem da lista de prompts É a ordem em que o jogador deve tocar as
/// cartas; a posição das cartas na tela é sorteada, independente disso.
class TutorialPrompt {
  const TutorialPrompt({required this.text, required this.answer});

  /// Texto exibido no painel de dicas.
  final String text;

  /// Carta que responde esta dica.
  final Particle answer;
}
