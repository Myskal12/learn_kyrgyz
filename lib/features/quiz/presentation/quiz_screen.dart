import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/learning_session_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/quiz_question_model.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.categoryId});
  final String categoryId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  LearningDirection? _lastDirection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId.isNotEmpty) {
        context.read<LearningSessionProvider>().setLastCategoryId(
          widget.categoryId,
        );
      }
      final direction = context.read<SettingsProvider>().direction;
      _lastDirection = direction;
      context.read<QuizProvider>().startWithDirection(
            widget.categoryId,
            direction,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isQuick = widget.categoryId.isEmpty;
    final direction = context.watch<SettingsProvider>().direction;
    if (_lastDirection != direction) {
      _lastDirection = direction;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<QuizProvider>().startWithDirection(
              widget.categoryId,
              direction,
            );
      });
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isQuick ? 'Экспресс-квиз' : 'Квиз'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF7F0E12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Consumer<QuizProvider>(
            builder: (context, quiz, _) {
              if (quiz.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (quiz.isSummary) {
                return _QuizSummary(provider: quiz);
              }

              final question = quiz.currentQuestion;
              if (question == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Бул категория үчүн суроолор табылган жок.',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => quiz.startWithDirection(
                          widget.categoryId,
                          direction,
                        ),
                        child: const Text('Кайра жүктөө'),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    Text(
                      'Суроо ${quiz.index + 1} / ${quiz.totalQuestions}',
                      style: AppTextStyles.body.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: quiz.progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: _QuizBody(
                            question: question,
                            answered: quiz.answered,
                            selected: quiz.selected,
                            options: quiz.options,
                            correct: question.correct,
                            onSelect: quiz.selectAnswer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textDark,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: quiz.answered
                            ? quiz.nextQuestion
                            : (quiz.selected == null ? null : quiz.submit),
                        child: Text(
                          quiz.answered
                              ? 'Кийинки'
                              : (quiz.selected == null
                                    ? 'Жоопту тандаңыз'
                                    : 'Текшерүү'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.question,
    required this.answered,
    required this.selected,
    required this.options,
    required this.correct,
    required this.onSelect,
  });

  final QuizQuestionModel question;
  final bool answered;
  final String? selected;
  final List<String> options;
  final String correct;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.question,
            style: AppTextStyles.heading.copyWith(
              color: Colors.white,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnswerButton(
                index: index,
                label: option,
                enabled: !answered,
                selected: selected == option,
                isCorrect: option == correct,
                showResult: answered,
                onTap: () => onSelect(option),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.index,
    required this.label,
    required this.enabled,
    required this.selected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool enabled;
  final bool selected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color border = Colors.black.withValues(alpha: 0.12);
    Color text = AppColors.textDark;
    IconData? icon;
    final optionLabel = String.fromCharCode(65 + (index % 26));

    if (showResult) {
      if (isCorrect) {
        background = AppColors.success.withValues(alpha: 0.18);
        border = AppColors.success;
        text = Colors.white;
        icon = Icons.check_circle;
      } else if (selected) {
        background = AppColors.error.withValues(alpha: 0.18);
        border = AppColors.error;
        text = Colors.white;
        icon = Icons.cancel;
      } else {
        background = Colors.white.withValues(alpha: 0.92);
        border = Colors.black.withValues(alpha: 0.12);
      }
    } else if (selected) {
      background = AppColors.accent.withValues(alpha: 0.85);
      border = AppColors.accent;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      constraints: const BoxConstraints(minHeight: 68),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Text(
                    optionLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: text,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.title.copyWith(
                      color: text,
                      fontSize: 19,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 12),
                  Icon(icon, color: text),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizSummary extends StatelessWidget {
  const _QuizSummary({required this.provider});

  final QuizProvider provider;

  @override
  Widget build(BuildContext context) {
    final mainTotal = provider.correctAnswers + provider.incorrectAnswers;
    final accuracy = mainTotal == 0
        ? 0
        : ((provider.correctAnswers / mainTotal) * 100).round();
    final mistakes = provider.mistakeDetails;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Жыйынтык',
            style: AppTextStyles.heading.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 20,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Негизги: туура',
                  value: provider.correctAnswers.toString(),
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Негизги: ката',
                  value: provider.incorrectAnswers.toString(),
                  color: AppColors.error,
                ),
                if (provider.reviewCorrectAnswers +
                        provider.reviewIncorrectAnswers >
                    0) ...[
                  const Divider(height: 28),
                  _SummaryRow(
                    label: 'Кайра окуу: туура',
                    value: provider.reviewCorrectAnswers.toString(),
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Кайра окуу: ката',
                    value: provider.reviewIncorrectAnswers.toString(),
                    color: AppColors.error,
                  ),
                ],
                const Divider(height: 32),
                Text(
                  '$accuracy%',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primary,
                    fontSize: 44,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.reviewSucceeded
                      ? 'Кайра окууда бардык каталарды оңдодуңуз.'
                      : 'Кайра окууда ${provider.unresolvedMistakesCount} сөз калды.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (mistakes.isNotEmpty) ...[
            Text(
              'Ката кеткен сөздөр',
              style: AppTextStyles.title.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: mistakes
                  .map((q) => Chip(label: Text('${q.question} → ${q.correct}')))
                  .toList(),
            ),
            const SizedBox(height: 18),
          ],
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: provider.restartFull,
            icon: const Icon(Icons.refresh),
            label: const Text('Квизди кайра баштоо'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: mistakes.isEmpty ? null : provider.reviewMistakesAgain,
            icon: const Icon(Icons.replay),
            label: const Text('Каталарды кайра өтүү'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Артка кайтуу'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(value, style: AppTextStyles.title.copyWith(color: color)),
      ],
    );
  }
}
