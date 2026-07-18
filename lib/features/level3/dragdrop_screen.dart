import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_assets.dart';
import '../../core/app_colors.dart';
import '../../core/audio_controller.dart';
import '../../core/characters.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/pause_button.dart';
import '../../core/widgets/phase_result.dart';
import '../level1/leideohm_screen.dart' show ProfessorWidget;
import '../level1/quiz_models.dart';
import 'circuit_models.dart';
import 'dragdrop_script.dart';
import 'widgets/circuit_board.dart';
import 'widgets/component_piece.dart';

/// Level 3 — drag & drop de montagem de circuitos (bloco final do jogo).
///
/// Uma quest por vez: o tabuleiro mostra o circuito com lacunas e o tray
/// embaixo traz as peças (certas + distratores) em ordem sorteada
/// (anti-decoreba). Peça certa encaixa (SFX); errada balança a lacuna e volta
/// ao tray (snap-back do `Draggable`) — cada erro conta. Preenchidas todas as
/// lacunas, o circuito LIGA (elétrons + lâmpada acesa) por um instante e a
/// fase avança. No fim, [PhaseResult]: quest sem erro = "acerto" nas
/// estrelas; [onFinished] recebe os [QuestResult]s.
class DragDropScreen extends StatefulWidget {
  const DragDropScreen({
    super.key,
    this.quests = dragQuests,
    this.music = AppAssets.level3Song,
    this.onFinished,
    this.random,
  });

  final List<CircuitQuest> quests;

  /// Música da fase (loop), trocada via [AudioController.startSceneMusic].
  final String music;

  /// Chamado no Continuar do resultado, com o resultado de cada quest.
  final ValueChanged<List<QuestResult>>? onFinished;

  /// Sorteio injetável para testes determinísticos.
  final Random? random;

  /// Tempo que o circuito fica ligado (animando) antes da próxima quest.
  static const Duration poweredBeat = Duration(milliseconds: 2200);

  @override
  State<DragDropScreen> createState() => _DragDropScreenState();
}

class _DragDropScreenState extends State<DragDropScreen> {
  late final Random _random = widget.random ?? Random();

  final List<QuestResult> _results = [];
  final Map<SlotSide, CircuitComponent> _placed = {};
  late List<CircuitComponent> _tray;
  var _index = 0;
  var _mistakes = 0;
  var _powered = false;
  var _finished = false;
  var _reported = false;
  Timer? _poweredTimer;

  CircuitQuest get _quest => widget.quests[_index];

  @override
  void initState() {
    super.initState();
    AudioController.instance.startSceneMusic(widget.music);
    _tray = _shuffledTray();
  }

  @override
  void dispose() {
    _poweredTimer?.cancel();
    AudioController.instance.stopSceneMusic(widget.music);
    super.dispose();
  }

  List<CircuitComponent> _shuffledTray() {
    final pieces = _quest.trayPieces;
    return [
      for (final i in shuffledOrder(pieces.length, _random)) pieces[i],
    ];
  }

  void _handleCorrectDrop(CircuitSlot slot) {
    AudioController.instance.playTouch();
    setState(() {
      _placed[slot.side] = slot.expected;
      _tray.remove(slot.expected);
      if (_placed.length == _quest.slots.length) {
        _powered = true;
        _poweredTimer = Timer(DragDropScreen.poweredBeat, _advance);
      }
    });
  }

  void _handleWrongDrop(CircuitSlot slot) {
    _mistakes++;
  }

  void _advance() {
    if (!mounted) return;
    setState(() {
      _results.add(QuestResult(quest: _quest, mistakes: _mistakes));
      if (_index == widget.quests.length - 1) {
        _finished = true;
        return;
      }
      _index++;
      _placed.clear();
      _mistakes = 0;
      _powered = false;
      _tray = _shuffledTray();
    });
  }

  void _handleContinue() {
    if (_reported) return;
    _reported = true;
    widget.onFinished?.call(List.unmodifiable(_results));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.r, 10.r, 4.r, 10.r),
                  child: _finished ? _buildResult() : _buildQuestColumn(),
                ),
              ),
              SizedBox(
                width: 272.r,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.r),
                  child: ProfessorWidget(
                    fala: _finished
                        ? dragDoneFala
                        : _powered
                            ? _quest.falaLigou
                            : _quest.fala,
                    pose: _finished || _powered
                        ? LinaPose.comemorando
                        : LinaPose.explicando,
                    height: screenHeight * 0.42,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final perfect = _results.where((r) => r.perfect).length;
    return PhaseResult(
      title: 'Circuitos montados!',
      scoreText:
          'Você montou $perfect de ${widget.quests.length} sem errar!',
      correct: perfect,
      total: widget.quests.length,
      onContinue: _handleContinue,
    );
  }

  Widget _buildQuestColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const PauseButton(),
            SizedBox(width: 10.r),
            Text(
              'Circuito ${_index + 1} de ${widget.quests.length}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        Expanded(
          child: CircuitBoard(
            quest: _quest,
            placed: _placed,
            powered: _powered,
            onCorrectDrop: _handleCorrectDrop,
            onWrongDrop: _handleWrongDrop,
          ),
        ),
        _Tray(pieces: _tray, enabled: !_powered),
      ],
    );
  }
}

/// Bandeja de peças: cada uma é um `Draggable` (some do tray só quando
/// encaixa; distratores ficam até o fim da quest).
class _Tray extends StatelessWidget {
  const _Tray({required this.pieces, required this.enabled});

  final List<CircuitComponent> pieces;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundTop.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.electricCyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final piece in pieces)
            IgnorePointer(
              ignoring: !enabled,
              child: Draggable<CircuitComponent>(
                key: ValueKey('tray-${piece.name}'),
                data: piece,
                feedback: ComponentPiece(
                  component: piece,
                  size: 62.r,
                  showLabel: false,
                ),
                childWhenDragging: Opacity(
                  opacity: 0.25,
                  child: ComponentPiece(component: piece, size: 52.r),
                ),
                child: ComponentPiece(component: piece, size: 52.r),
              ),
            ),
        ],
      ),
    );
  }
}
