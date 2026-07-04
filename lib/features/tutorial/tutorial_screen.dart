import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_assets.dart';
import '../../core/app_colors.dart';
import '../../core/audio_controller.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sheet_sprite.dart';
import '../../core/widgets/sound_button.dart';
import '../../core/widgets/sound_toggle_button.dart';
import '../../core/widgets/speech_balloon.dart';
import '../cutscene/cutscene_frame.dart';
import 'tutorial_prompt.dart';
import 'tutorial_script.dart';

/// Tutorial do quiz de cartas, exibido após a cutscene e antes do level 1.
///
/// Três atos:
/// 1. **Intro** — o Link explica com balões de fala (toque avança).
/// 2. **Play** — o painel de dicas surge e as cartas de partícula CAEM em
///    ordem sorteada; o jogador toca nas cartas na ordem das dicas. Acerto
///    marca a carta com o número da sequência e risca a dica; erro balança
///    a carta.
/// 3. **Done** — fala final; um toque chama [onFinished].
///
/// As falas e dicas moram em `tutorial_script.dart` (arquivo editável).
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({
    super.key,
    this.introFrames = tutorialIntro,
    this.playFrame = tutorialPlayFrame,
    this.doneFrame = tutorialDoneFrame,
    this.prompts = tutorialPrompts,
    this.onFinished,
    this.random,
  });

  /// Balões introdutórios; vazio pula direto para as cartas.
  final List<CutsceneFrame> introFrames;

  /// Fala mostrada durante a interação com as cartas.
  final CutsceneFrame playFrame;

  /// Fala final, após acertar todas.
  final CutsceneFrame doneFrame;

  /// Dicas do painel, na ordem em que devem ser respondidas.
  final List<TutorialPrompt> prompts;

  /// Disparado ao concluir o tutorial (toque após a fala final).
  final VoidCallback? onFinished;

  /// Fonte do sorteio da posição das cartas (injetável para testes).
  final Random? random;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

enum _Phase { intro, play, done }

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  static const int _msPerChar = 28;

  /// Proporção das cartas (`proton/eletron/neutron.png`: 202×233).
  static const double _cardAspect = 202 / 233;

  late final AnimationController _typeController =
      AnimationController(vsync: this);
  late final AnimationController _fallController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  /// Cartas na ordem sorteada dos slots (esquerda → direita).
  late final List<Particle> _cards;

  /// Cartas já acertadas → número da sequência (1-based).
  final Map<Particle, int> _answered = {};

  Particle? _shaking;
  _Phase _phase = _Phase.intro;
  int _introIndex = 0;
  bool _finished = false;
  bool _precached = false;

  CutsceneFrame get _frame => switch (_phase) {
        _Phase.intro => widget.introFrames[_introIndex],
        _Phase.play => widget.playFrame,
        _Phase.done => widget.doneFrame,
      };

  @override
  void initState() {
    super.initState();
    _cards = [for (final p in widget.prompts) p.answer]
      ..shuffle(widget.random ?? Random());
    AudioController.instance.startSceneMusic(AppAssets.level1Song);
    if (widget.introFrames.isEmpty) {
      _phase = _Phase.play;
      _fallController.forward();
    }
    _playFrame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    precacheImage(const AssetImage(AppAssets.backgroundGame), context);
    final sprites = {
      for (final f in widget.introFrames) f.characterSprite,
      widget.playFrame.characterSprite,
      widget.doneFrame.characterSprite,
    };
    for (final path in sprites) {
      precacheImage(AssetImage(path), context);
    }
    for (final card in _cards) {
      precacheImage(AssetImage(card.cardAsset), context);
    }
  }

  @override
  void dispose() {
    AudioController.instance.stopSceneMusic(AppAssets.level1Song);
    _typeController.dispose();
    _fallController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _playFrame() {
    final length = _frame.text.length;
    _typeController
      ..duration = Duration(
        milliseconds: (length * _msPerChar).clamp(400, 6000),
      )
      ..forward(from: 0);
  }

  void _handleScreenTap() {
    if (_finished) return;
    if (_phase == _Phase.play) {
      // Na fase de jogo o toque útil é nas cartas; só revela a fala se
      // ainda estiver "digitando".
      if (_typeController.isAnimating) _typeController.value = 1;
      return;
    }
    AudioController.instance.playTouchScene();
    if (_typeController.isAnimating) {
      _typeController.value = 1; // revela a fala inteira de uma vez
      return;
    }
    if (_phase == _Phase.done) {
      _finish();
      return;
    }
    if (_introIndex == widget.introFrames.length - 1) {
      setState(() => _phase = _Phase.play);
      _fallController.forward();
    } else {
      setState(() => _introIndex++);
    }
    _playFrame();
  }

  void _handleCardTap(Particle card) {
    if (_phase != _Phase.play || _answered.containsKey(card)) return;
    final expected = widget.prompts[_answered.length].answer;
    if (card == expected) {
      AudioController.instance.playTouch();
      setState(() => _answered[card] = _answered.length + 1);
      if (_answered.length == widget.prompts.length) {
        setState(() => _phase = _Phase.done);
        _playFrame();
      }
    } else {
      AudioController.instance.playTouchScene();
      setState(() => _shaking = card);
      _shakeController.forward(from: 0);
    }
  }

  void _finish() {
    if (_finished) return;
    setState(() => _finished = true);
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: GestureDetector(
        onTap: _handleScreenTap,
        behavior: HitTestBehavior.opaque,
        child: GameBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildQuizColumn()),
                      _buildGuideColumn(screenHeight),
                    ],
                  ),
                ),

                // Botão de pausa — canto superior esquerdo.
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: const _PauseButton(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Coluna esquerda: painel de dicas no topo e cartas "no chão".
  /// Invisível durante a intro; surge quando as cartas caem.
  Widget _buildQuizColumn() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 14.r, 4.r, 12.r),
      child: AnimatedOpacity(
        opacity: _phase == _Phase.intro ? 0 : 1,
        duration: const Duration(milliseconds: 350),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              // Desvia do botão de pausa.
              padding: EdgeInsets.only(left: 52.r),
              child: _PromptPanel(
                prompts: widget.prompts,
                answeredCount: _answered.length,
              ),
            ),
            const Spacer(),
            _buildCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildCards() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fallController, _shakeController]),
      builder: (context, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var slot = 0; slot < _cards.length; slot++) ...[
            if (slot > 0) SizedBox(width: 12.r),
            _buildCard(_cards[slot], slot),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(Particle card, int slot) {
    // Queda: cada carta entra com um pequeno atraso (stagger) e "quica" ao
    // pousar no slot.
    final fall = CurvedAnimation(
      parent: _fallController,
      curve: Interval(slot * 0.18, 0.55 + slot * 0.15, curve: Curves.bounceOut),
    ).value;
    final drop = (1 - fall) * -1.4 * MediaQuery.sizeOf(context).height;
    final shake = _shaking == card
        ? sin(_shakeController.value * pi * 5) *
            9.r *
            (1 - _shakeController.value)
        : 0.0;
    final number = _answered[card];

    return Transform.translate(
      offset: Offset(shake, drop),
      child: GestureDetector(
        key: ValueKey(card),
        onTap: () => _handleCardTap(card),
        child: SizedBox(
          width: 138.r,
          child: AspectRatio(
            aspectRatio: _cardAspect,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  card.cardAsset,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
                if (number != null)
                  Positioned(
                    top: 6.r,
                    right: 6.r,
                    child: _OrderBadge(number),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Coluna direita: balão de fala no topo e Link "no chão".
  Widget _buildGuideColumn(double screenHeight) {
    return SizedBox(
      width: 272.r,
      child: Padding(
        padding: EdgeInsets.only(right: 12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12.r),
              child: AnimatedBuilder(
                animation: _typeController,
                builder: (context, _) {
                  final full = _frame.text;
                  final shown = full.substring(
                    0,
                    (full.length * _typeController.value).round(),
                  );
                  return SpeechBalloon(
                    text: shown,
                    showContinueHint:
                        !_typeController.isAnimating && _phase != _Phase.play,
                    isLast: _phase == _Phase.done,
                  );
                },
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: SheetSprite(
                asset: _frame.characterSprite,
                columns: _frame.spriteColumns,
                index: _frame.spriteIndex,
                height: screenHeight * 0.42,
                // Mesmos trims da cutscene: a caixa corresponde ao desenho
                // visível do Link (linhas ~18%–67% da célula).
                topTrim: 0.17,
                bottomTrim: 0.31,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painel branco com as dicas numeradas; dicas respondidas ficam riscadas.
class _PromptPanel extends StatelessWidget {
  const _PromptPanel({required this.prompts, required this.answeredCount});

  final List<TutorialPrompt> prompts;
  final int answeredCount;

  static const Color _ink = Color(0xFF15233B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: const Color(0xF2F4F7FB),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10.r,
            offset: Offset(0, 3.r),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < prompts.length; i++)
            Text(
              '${i + 1}. ${prompts[i].text}',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                height: 1.45,
                color: i < answeredCount
                    ? _ink.withValues(alpha: 0.4)
                    : _ink,
                decoration:
                    i < answeredCount ? TextDecoration.lineThrough : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// Selo amarelo com o número da sequência, exibido na carta acertada.
class _OrderBadge extends StatelessWidget {
  const _OrderBadge(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.electricYellow,
        border: Border.all(color: Colors.white, width: 2.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6.r,
          ),
        ],
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF15233B),
        ),
      ),
    );
  }
}

/// Botão circular de pausa; abre o diálogo com som e sair.
class _PauseButton extends StatelessWidget {
  const _PauseButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          AudioController.instance.playTouch();
          showDialog<void>(
            context: context,
            builder: (_) => const _PauseDialog(),
          );
        },
        child: SizedBox(
          width: 44.r,
          height: 44.r,
          child: Icon(
            Icons.pause_rounded,
            color: AppColors.electricCyan,
            size: 24.r,
          ),
        ),
      ),
    );
  }
}

class _PauseDialog extends StatelessWidget {
  const _PauseDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundTop,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Row(
        children: [
          Text(
            'Pausa',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22.sp,
            ),
          ),
          const Spacer(),
          const SoundToggleButton(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SoundButton(
            label: 'Continuar',
            icon: Icons.play_arrow_rounded,
            primary: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: 12.r),
          SoundButton(
            label: 'Voltar ao menu',
            icon: Icons.exit_to_app_rounded,
            // Fecha o diálogo e sai do tutorial (a rota abaixo é o menu).
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
          ),
        ],
      ),
    );
  }
}
