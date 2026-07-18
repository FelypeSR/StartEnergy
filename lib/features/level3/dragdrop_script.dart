import 'circuit_models.dart';

/// ARQUIVO EDITÁVEL: as 4 quests do drag & drop (level 3) e as falas da Lina.
///
/// Progressão: circuito mínimo → interruptor → resistor (liga com a Lei de
/// Ohm) → escolher o material condutor. A pilha fica sempre à esquerda do
/// laço; a lâmpada, no topo.
///
/// TODO(falas): textos provisórios — SUBSTITUIR pelas falas finais.
const List<CircuitQuest> dragQuests = [
  CircuitQuest(
    fala: 'Monte o circuito: pilha, lâmpada e fio no lugar certo!',
    falaLigou: 'Ligou! O caminho fechou e a corrente circula.',
    slots: [
      CircuitSlot(expected: CircuitComponent.battery, side: SlotSide.left),
      CircuitSlot(expected: CircuitComponent.bulb, side: SlotSide.top),
      CircuitSlot(expected: CircuitComponent.wire, side: SlotSide.right),
    ],
  ),
  CircuitQuest(
    fala: 'Agora com um interruptor, pra ligar e desligar quando quiser!',
    falaLigou: 'Interruptor fechado, lâmpada acesa!',
    slots: [
      CircuitSlot(expected: CircuitComponent.battery, side: SlotSide.left),
      CircuitSlot(expected: CircuitComponent.bulb, side: SlotSide.top),
      CircuitSlot(expected: CircuitComponent.switchKey, side: SlotSide.right),
    ],
    distractors: [CircuitComponent.resistor],
  ),
  CircuitQuest(
    fala: 'Lembra da Lei de Ohm? Coloque o resistor pra controlar a corrente!',
    falaLigou: 'O resistor segura a corrente — tudo sob controle!',
    slots: [
      CircuitSlot(expected: CircuitComponent.battery, side: SlotSide.left),
      CircuitSlot(expected: CircuitComponent.bulb, side: SlotSide.top),
      CircuitSlot(expected: CircuitComponent.resistor, side: SlotSide.bottom),
      CircuitSlot(expected: CircuitComponent.wire, side: SlotSide.right),
    ],
    distractors: [CircuitComponent.wood],
  ),
  CircuitQuest(
    fala: 'Só um destes materiais deixa a corrente passar. Qual é o condutor?',
    falaLigou: 'Isso! O cobre é condutor — a corrente atravessa ele!',
    slots: [
      CircuitSlot(expected: CircuitComponent.battery, side: SlotSide.left),
      CircuitSlot(expected: CircuitComponent.bulb, side: SlotSide.top),
      CircuitSlot(expected: CircuitComponent.copper, side: SlotSide.right),
    ],
    distractors: [CircuitComponent.rubber, CircuitComponent.wood],
  ),
];

/// Fala da Lina no resultado final (endphase).
/// TODO(falas): texto provisório.
const String dragDoneFala = 'Você montou todos os circuitos. Que eletricista!';
