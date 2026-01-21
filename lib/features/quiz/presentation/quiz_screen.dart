import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_top_nav.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.categoryId});
  final String categoryId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  LearningDirection? _lastDirection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId.isNotEmpty) {
        ref
            .read(learningSessionProvider)
            .setLastCategoryId(widget.categoryId);
      }
      final direction = ref.read(learningDirectionProvider);
      _lastDirection = direction;
      ref.read(quizProvider).startWithDirection(widget.categoryId, direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isQuick = widget.categoryId.isEmpty;
    final direction = ref.watch(learningDirectionProvider);
    if (_lastDirection != direction) {
      _lastDirection = direction;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(quizProvider).startWithDirection(widget.categoryId, direction);
      });
    }
    final quiz = ref.watch(quizProvider);

    return AppShell(
      title: isQuick ? 'Экспресс-квиз' : 'Квиз',
      subtitle: 'Кыска текшерүү',
      activeTab: AppTab.learn,
      tone: AppTopNavTone.dark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Builder(
              builder: (context) {
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
                        AppButton(
                          variant: AppButtonVariant.accent,
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Суроо ${quiz.index + 1} / ${quiz.totalQuestions}',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${(quiz.progress * 100).round()}%',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: quiz.progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _QuizBody(
                          question: question,
                          answered: quiz.answered,
                          selected: quiz.selected,
                          options: quiz.options,
                          correct: question.correct,
                          onSelect: quiz.selectAnswer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        variant: AppButtonVariant.accent,
                        size: AppButtonSize.lg,
                        fullWidth: true,
                        disabled: !quiz.answered && quiz.selected == null,
                        onPressed: quiz.answered
                            ? quiz.nextQuestion
                            : (quiz.selected == null ? null : quiz.submit),
                        child: Text(
                          quiz.answered
                              ? 'Кийинки'
                              : (quiz.selected == null
                                  ? 'Жоопту тандаңыз'
                                  : 'Текшерүү'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
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
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 18),
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
    Color text = AppColors.textDark;
    Color circleBackground = AppColors.mutedSurface;
    Color circleText = AppColors.textDark;
    IconData? icon;
    Border? border;
    final optionLabel = String.fromCharCode(65 + (index % 26));

    if (showResult) {
      if (isCorrect) {
        background = AppColors.success;
        text = Colors.white;
        circleBackground = Colors.white.withValues(alpha: 0.2);
        circleText = Colors.white;
        icon = Icons.check;
      } else if (selected) {
        background = AppColors.accent;
        text = Colors.white;
        circleBackground = Colors.white.withValues(alpha: 0.2);
        circleText = Colors.white;
        icon = Icons.close;
      } else {
        background = Colors.white.withValues(alpha: 0.4);
        text = AppColors.muted;
        circleBackground = AppColors.muted.withValues(alpha: 0.2);
        circleText = AppColors.muted;
      }
    } else if (selected) {
      border = Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: border,
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
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleBackground,
                  ),
                  child: icon != null
                      ? Icon(icon, color: circleText, size: 22)
                      : Text(
                          optionLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: circleText,
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
              boxShadow: [
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
                  color: AppColors.accent,
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
                    color: AppColors.accent,
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
                  .map(
                    (q) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${q.question} - ${q.correct}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
          ],
          AppButton(
            variant: AppButtonVariant.accent,
            fullWidth: true,
            onPressed: provider.restartFull,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.refresh, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text('Квизди кайра баштоо'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            variant: AppButtonVariant.outlined,
            fullWidth: true,
            disabled: mistakes.isEmpty,
            onPressed: mistakes.isEmpty ? null : provider.reviewMistakesAgain,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.replay, size: 18),
                SizedBox(width: 8),
                Text('Каталарды кайра өтүү'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            variant: AppButtonVariant.outlined,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
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
