import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/app_top_nav.dart';
import '../../../shared/widgets/session_summary_panel.dart';
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
        ref.read(learningSessionProvider).setLastCategoryId(widget.categoryId);
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
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/practice',
      showBottomNav: false,
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
                  return const AppLoadingState(
                    title: 'Квиз жүктөлүүдө',
                    message: 'Суроолор жана варианттар даярдалып жатат.',
                    foregroundColor: Colors.white,
                    indicatorColor: Colors.white,
                  );
                }
                if (quiz.isSummary) {
                  return _QuizSummary(
                    provider: quiz,
                    categoryId: widget.categoryId,
                  );
                }
                if (quiz.errorMessage != null) {
                  return AppErrorState(
                    message: quiz.errorMessage!,
                    foregroundColor: Colors.white,
                    buttonVariant: AppButtonVariant.accent,
                    onAction: () =>
                        quiz.startWithDirection(widget.categoryId, direction),
                  );
                }

                final question = quiz.currentQuestion;
                if (question == null) {
                  return AppEmptyState(
                    title: 'Суроолор табылган жок',
                    message:
                        'Бул категория үчүн суроолор же fallback сөздөр табылган жок.',
                    icon: Icons.quiz_outlined,
                    foregroundColor: Colors.white,
                    buttonVariant: AppButtonVariant.accent,
                    actionLabel: 'Кайра жүктөө',
                    onAction: () =>
                        quiz.startWithDirection(widget.categoryId, direction),
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
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
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
          if (answered) ...[
            const SizedBox(height: 6),
            _AnswerFeedbackCard(
              selected: selected,
              correct: correct,
              isCorrect: selected == correct,
            ),
          ],
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
  const _QuizSummary({required this.provider, required this.categoryId});

  final QuizProvider provider;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final mainTotal = provider.correctAnswers + provider.incorrectAnswers;
    final accuracy = mainTotal == 0
        ? 0
        : ((provider.correctAnswers / mainTotal) * 100).round();
    final mistakes = provider.mistakeDetails;
    final mistakeTags = mistakes
        .take(6)
        .map((item) => '${item.question} → ${item.correct}')
        .toList();
    final nextRoute = categoryId.isNotEmpty
        ? '/sentence-builder/$categoryId'
        : '/categories';
    final nextLabel = categoryId.isNotEmpty
        ? 'Сүйлөм түзүүгө өтүү'
        : 'Категория тандаңыз';

    return SessionSummaryPanel(
      title: 'Квиз аяктады',
      headline: _headline(accuracy),
      message: provider.reviewSucceeded
          ? 'Каталар жабылды. Эми натыйжаны активдүү колдонуу үчүн башка режимге өтүңүз.'
          : 'Дагы ${provider.unresolvedMistakesCount} суроо толук бекей элек. Кайра өтүү пайдалуу болот.',
      metrics: [
        SessionSummaryMetric(
          label: 'Туура',
          value: provider.correctAnswers.toString(),
          color: AppColors.success,
        ),
        SessionSummaryMetric(
          label: 'Ката',
          value: provider.incorrectAnswers.toString(),
          color: AppColors.accent,
        ),
        SessionSummaryMetric(
          label: 'Кайра окуу',
          value:
              '${provider.reviewCorrectAnswers + provider.reviewIncorrectAnswers}',
          color: AppColors.primary,
        ),
        SessionSummaryMetric(
          label: 'Тактык',
          value: '$accuracy%',
          color: AppColors.primary,
        ),
      ],
      noteTitle: 'Жакшы кийинки кадам',
      noteMessage: provider.reviewSucceeded
          ? 'Квизден кийин сүйлөм түзүү же карточка режими маалыматты узагыраак сактоого жардам берет.'
          : 'Алгач каталарды кайра өтүп, андан кийин башка режимге өтсөңүз натыйжа жакшыраак бекет.',
      tagsTitle: mistakeTags.isNotEmpty
          ? 'Кайра кароого калган суроолор'
          : null,
      tags: mistakeTags,
      primaryAction: SessionSummaryAction(
        label: mistakeTags.isNotEmpty ? 'Каталарды кайра өтүү' : nextLabel,
        onPressed: mistakeTags.isNotEmpty
            ? provider.reviewMistakesAgain
            : () => context.go(nextRoute),
        variant: AppButtonVariant.accent,
      ),
      secondaryAction: SessionSummaryAction(
        label: mistakeTags.isNotEmpty ? nextLabel : 'Квизди кайра баштоо',
        onPressed: mistakeTags.isNotEmpty
            ? () => context.go(nextRoute)
            : provider.restartFull,
        variant: AppButtonVariant.outlined,
      ),
      tertiaryLabel: 'Практикага кайтуу',
      onTertiaryTap: () => context.go('/practice'),
    );
  }

  String _headline(int accuracy) {
    if (provider.reviewSucceeded && accuracy >= 80) {
      return 'Жакшы текшерүү болду';
    }
    if (accuracy >= 60) {
      return 'Негизги темп жакшы';
    }
    return 'Дагы бир айлампа жардам берет';
  }
}

class _AnswerFeedbackCard extends StatelessWidget {
  const _AnswerFeedbackCard({
    required this.selected,
    required this.correct,
    required this.isCorrect,
  });

  final String? selected;
  final String correct;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? 'Туура жооп' : 'Жооп түшүндүрмөсү',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCorrect
                ? 'Сиз туура вариантты тандадыңыз: $correct'
                : 'Сиз тандадыңыз: ${selected ?? 'жооп жок'}',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              'Туурасы: $correct',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
