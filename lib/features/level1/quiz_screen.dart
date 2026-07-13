import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_assets.dart';
import '../../core/app_colors.dart';
import '../../core/audio_controller.dart';
import '../../core/widgets/game_background.dart';
import '../../core/widgets/sound_button.dart';
import 'quiz_models.dart';
import 'quiz_script.dart';

/// Level 1 — Quiz 1.
///
/// Uma questão por vez; as alternativas usam o botão padrão do menu e têm a
/// posição re-sorteada a cada questão (anti-decoreba). O toque numa
/// alternativa grava o [AnswerResult] e **avança sempre** — sem feedback de
/// acerto/erro durante a partida; a revisão acontece na endphase, que recebe
/// os resultados via [onFinished]. Respondida a última questão, a tela mostra
/// o resultado em estrelas ([starsForCorrect]) e o botão Continuar dispara
/// [onFinished].
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.questions = quizQuestions,
    this.onFinished,
    this.random,
  });

  final List<QuizQuestion> questions;

  /// Chamado ao responder a última questão, com todos os resultados.
  final ValueChanged<List<AnswerResult>>? onFinished;

  /// Sorteio injetável para testes determinísticos.
  final Random? random;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  /// Faixa reservada à direita para os widgets da fase (guia, placar etc.).
  static const double _reservedRightWidth = 96;

  late final Random _random = widget.random ?? Random();
  final List<AnswerResult> _results = [];
  var _index = 0;
  late List<int> _order;
  var _finished = false;
  var _reported = false;

  QuizQuestion get _question => widget.questions[_index];

  @override
  void initState() {
    super.initState();
    AudioController.instance.startSceneMusic(AppAssets.level1Song);
    _order = shuffledOrder(_question.options.length, _random);
  }

  @override
  void dispose() {
    AudioController.instance.stopSceneMusic(AppAssets.level1Song);
    super.dispose();
  }

  void _handleOption(int optionIndex) {
    if (_finished) return;
    _results.add(
      AnswerResult(question: _question, selectedIndex: optionIndex),
    );
    if (_index == widget.questions.length - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _order = shuffledOrder(_question.options.length, _random);
    });
  }

  void _handleContinue() {
    if (_reported) return;
    _reported = true;
    widget.onFinished?.call(List.unmodifiable(_results));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        asset: AppAssets.backgroundLevel1,
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _finished
                    ? _QuizResult(
                        correct: _results.where((r) => r.correct).length,
                        total: widget.questions.length,
                        onContinue: _handleContinue,
                      )
                    : _buildQuizColumn(),
              ),
              SizedBox(width: _reservedRightWidth.r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizColumn() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 16.r, 8.r, 16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questão ${_index + 1} de ${widget.questions.length}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 8.r),
          _QuestionPanel(text: _question.text),
          const Spacer(),
          for (final optionIndex in _order) ...[
            SoundButton(
              key: ValueKey('option-$optionIndex'),
              label: _question.options[optionIndex],
              width: 460.r,
              onPressed: () => _handleOption(optionIndex),
            ),
            SizedBox(height: 12.r),
          ],
        ],
      ),
    );
  }
}

/// Resultado do quiz: 1–3 estrelas ([starsForCorrect]) surgindo com bounce
/// escalonado, o placar de acertos e o botão Continuar.
class _QuizResult extends StatefulWidget {
  const _QuizResult({
    required this.correct,
    required this.total,
    required this.onContinue,
  });

  final int correct;
  final int total;
  final VoidCallback onContinue;

  @override
  State<_QuizResult> createState() => _QuizResultState();
}

class _QuizResultState extends State<_QuizResult>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stars = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void dispose() {
    _stars.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earned = starsForCorrect(widget.correct, widget.total);
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 20.r),
        decoration: BoxDecoration(
          color: AppColors.backgroundTop.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.electricCyan.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quiz concluído!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.r),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _stars,
                      curve: Interval(
                        i * 0.22,
                        i * 0.22 + 0.34,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Icon(
                      i < earned
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 52.r,
                      color: i < earned
                          ? AppColors.electricYellow
                          : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.r),
            Text(
              'Você acertou ${widget.correct} de ${widget.total}!',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 16.r),
            SoundButton(
              label: 'Continuar',
              width: 220.r,
              onPressed: widget.onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Painel do enunciado, no mesmo estilo dos painéis das outras telas.
class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 14.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundTop.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.electricCyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 19.sp,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}