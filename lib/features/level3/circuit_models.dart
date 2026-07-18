/// Componentes das quests de montagem de circuito (peças e distratores).
enum CircuitComponent {
  battery('Pilha'),
  wire('Fio'),
  bulb('Lâmpada'),
  switchKey('Interruptor'),
  resistor('Resistor'),
  copper('Cobre'),
  rubber('Borracha'),
  wood('Madeira');

  const CircuitComponent(this.label);

  /// Nome exibido sob a peça no tray e na silhueta da lacuna.
  final String label;
}

/// Lado do laço do circuito onde a lacuna fica (a pilha ocupa sempre a
/// esquerda, como no `OhmCircuit`; os demais variam por quest).
enum SlotSide { left, top, right, bottom }

/// Uma lacuna do tabuleiro: o lado do laço e a peça que ela espera.
class CircuitSlot {
  const CircuitSlot({required this.expected, required this.side});

  final CircuitComponent expected;
  final SlotSide side;
}

/// Uma quest de montagem: fala da Lina, lacunas do tabuleiro e distratores
/// que aparecem no tray junto com as peças certas.
class CircuitQuest {
  const CircuitQuest({
    required this.fala,
    required this.falaLigou,
    required this.slots,
    this.distractors = const [],
  });

  /// Instrução da Lina durante a montagem.
  final String fala;

  /// Comemoração da Lina enquanto o circuito ligado anima.
  final String falaLigou;

  final List<CircuitSlot> slots;

  /// Peças a mais no tray que não encaixam em lacuna nenhuma.
  final List<CircuitComponent> distractors;

  /// Todas as peças do tray (certas + distratores), na ordem canônica —
  /// a tela sorteia a exibição via `shuffledOrder` (anti-decoreba).
  List<CircuitComponent> get trayPieces => [
        for (final slot in slots) slot.expected,
        ...distractors,
      ];
}

/// Resultado de uma quest — os erros alimentam as estrelas da endphase
/// (quest sem nenhum erro conta como "acerto" em `starsForCorrect`).
class QuestResult {
  const QuestResult({required this.quest, required this.mistakes});

  final CircuitQuest quest;

  /// Tentativas de encaixe erradas (peça solta numa lacuna que não a espera).
  final int mistakes;

  bool get perfect => mistakes == 0;
}
