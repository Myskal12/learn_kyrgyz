import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/app_top_nav.dart';
import '../../../shared/widgets/learning_direction_nav_button.dart';
import '../../../shared/widgets/session_summary_panel.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.categoryId});
  final String categoryId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late final ProviderSubscription<LearningDirection> _directionSubscription;

  @override
  void initState() {
    super.initState();
    _directionSubscription = ref.listenManual<LearningDirection>(
      learningDirectionProvider,
      (previous, next) {
        if (previous == next) return;
        ref.read(quizProvider).startWithDirection(widget.categoryId, next);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final direction = ref.read(learningDirectionProvider);
      if (widget.categoryId.isNotEmpty) {
        ref.read(learningSessionProvider).setLastCategoryId(widget.categoryId);
      }
      ref.read(quizProvider).startWithDirection(widget.categoryId, direction);
    });
  }

  @override
  void dispose() {
    _directionSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isQuick = widget.categoryId.isEmpty;
    final quiz = ref.watch(quizProvider);
    final direction = ref.watch(learningDirectionProvider);

    return AppShell(
      title: isQuick
          ? context.tr(
              ky: 'Экспресс-квиз',
              en: 'Quick quiz',
              ru: 'Экспресс-квиз',
            )
          : context.tr(ky: 'Квиз', en: 'Quiz', ru: 'Квиз'),
      subtitle: context.tr(
        ky: 'Кыска текшерүү',
        en: 'Short check',
        ru: 'Короткая проверка',
      ),
      activeTab: AppTab.learn,
      tone: AppTopNavTone.dark,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/practice',
      showBottomNav: false,
      topNavTrailing: const LearningDirectionNavButton(
        tone: AppTopNavTone.dark,
      ),
      topNavTrailingWidth: 108,
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
                  return AppLoadingState(
                    title: context.tr(
                      ky: 'Квиз жүктөлүүдө',
                      en: 'Quiz is loading',
                      ru: 'Квиз загружается',
                    ),
                    message: context.tr(
                      ky: 'Суроолор жана варианттар даярдалып жатат.',
                      en: 'Questions and options are being prepared.',
                      ru: 'Подготавливаются вопросы и варианты.',
                    ),
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
                    title: context.tr(
                      ky: 'Суроолор табылган жок',
                      en: 'No questions found',
                      ru: 'Вопросы не найдены',
                    ),
                    message: context.tr(
                      ky: 'Бул категория үчүн суроолор же fallback сөздөр табылган жок.',
                      en: 'No questions or fallback words were found for this category.',
                      ru: 'Для этой категории не найдены вопросы или резервные слова.',
                    ),
                    icon: Icons.quiz_outlined,
                    foregroundColor: Colors.white,
                    buttonVariant: AppButtonVariant.accent,
                    actionLabel: context.tr(
                      ky: 'Кайра жүктөө',
                      en: 'Reload',
                      ru: 'Перезагрузить',
                    ),
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
                            context.tr(
                              ky: 'Суроо ${quiz.index + 1} / ${quiz.totalQuestions}',
                              en: 'Question ${quiz.index + 1} / ${quiz.totalQuestions}',
                              ru: 'Вопрос ${quiz.index + 1} / ${quiz.totalQuestions}',
                            ),
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Text(
                            direction.helperTextOf(context),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                              ? context.tr(
                                  ky: 'Кийинки',
                                  en: 'Next',
                                  ru: 'Дальше',
                                )
                              : (quiz.selected == null
                                    ? context.tr(
                                        ky: 'Жоопту тандаңыз',
                                        en: 'Choose an answer',
                                        ru: 'Выберите ответ',
                                      )
                                    : context.tr(
                                        ky: 'Текшерүү',
                                        en: 'Check',
                                        ru: 'Проверить',
                                      )),
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
        ? context.tr(
            ky: 'Сүйлөм түзүүгө өтүү',
            en: 'Go to sentence builder',
            ru: 'Перейти к построению предложений',
          )
        : context.tr(
            ky: 'Категория тандаңыз',
            en: 'Choose a category',
            ru: 'Выберите категорию',
          );
    final reviewRoute = categoryId.isNotEmpty
        ? '/flashcards/$categoryId?mode=review'
        : '/categories';
    final reviewLabel = categoryId.isNotEmpty
        ? context.tr(
            ky: 'Кайталоо кезегин ачуу',
            en: 'Open review queue',
            ru: 'Открыть очередь повторения',
          )
        : context.tr(
            ky: 'Категория тандаңыз',
            en: 'Choose a category',
            ru: 'Выберите категорию',
          );

    return SessionSummaryPanel(
      title: context.tr(
        ky: 'Квиз аяктады',
        en: 'Quiz completed',
        ru: 'Квиз завершён',
      ),
      headline: _headline(context, accuracy),
      message: provider.reviewSucceeded
          ? context.tr(
              ky: 'Каталар жабылды. Эми натыйжаны активдүү колдонуу үчүн башка режимге өтүңүз.',
              en: 'Mistakes are cleared. Now switch to another mode to actively use the result.',
              ru: 'Ошибки закрыты. Теперь перейдите в другой режим, чтобы активнее использовать результат.',
            )
          : context.tr(
              ky: 'Дагы ${provider.unresolvedMistakesCount} суроо толук бекей элек. Аларды review queue аркылуу жабуу жакшы кийинки кадам болот.',
              en: '${provider.unresolvedMistakesCount} questions are still not fully solid. Closing them through the review queue is the best next step.',
              ru: 'Ещё ${provider.unresolvedMistakesCount} вопросов не закреплены полностью. Лучший следующий шаг — закрыть их через очередь повторения.',
            ),
      metrics: [
        SessionSummaryMetric(
          label: context.tr(ky: 'Туура', en: 'Correct', ru: 'Верно'),
          value: provider.correctAnswers.toString(),
          color: AppColors.success,
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Ката', en: 'Wrong', ru: 'Ошибки'),
          value: provider.incorrectAnswers.toString(),
          color: AppColors.accent,
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Кайра окуу', en: 'Review', ru: 'Повтор'),
          value:
              '${provider.reviewCorrectAnswers + provider.reviewIncorrectAnswers}',
          color: AppColors.primary,
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Тактык', en: 'Accuracy', ru: 'Точность'),
          value: '$accuracy%',
          color: AppColors.primary,
        ),
      ],
      noteTitle: context.tr(
        ky: 'Жакшы кийинки кадам',
        en: 'Best next step',
        ru: 'Лучший следующий шаг',
      ),
      noteMessage: provider.reviewSucceeded
          ? context.tr(
              ky: 'Квизден кийин сүйлөм түзүү же карточка режими маалыматты узагыраак сактоого жардам берет.',
              en: 'After the quiz, sentence building or flashcards help retain the material longer.',
              ru: 'После квиза построение предложений или карточки помогают дольше удерживать материал.',
            )
          : context.tr(
              ky: 'Ката кеткен жооптор буга чейин эле прогресске review item болуп жазылды. Аларды карточка режиминде кайра жабуу ылдамыраак бекемдейт.',
              en: 'Incorrect answers are already added to progress as review items. Closing them in flashcards reinforces them faster.',
              ru: 'Ошибочные ответы уже записаны в прогресс как элементы повторения. Закрыть их в карточках получится быстрее.',
            ),
      tagsTitle: mistakeTags.isNotEmpty
          ? context.tr(
              ky: 'Кайра кароого калган суроолор',
              en: 'Questions left for review',
              ru: 'Вопросы, оставшиеся на повторение',
            )
          : null,
      tags: mistakeTags,
      primaryAction: SessionSummaryAction(
        label: mistakeTags.isNotEmpty ? reviewLabel : nextLabel,
        onPressed: () =>
            context.go(mistakeTags.isNotEmpty ? reviewRoute : nextRoute),
        variant: AppButtonVariant.accent,
      ),
      secondaryAction: SessionSummaryAction(
        label: mistakeTags.isNotEmpty
            ? context.tr(
                ky: 'Каталарды кайра өтүү',
                en: 'Retry mistakes',
                ru: 'Повторить ошибки',
              )
            : context.tr(
                ky: 'Квизди кайра баштоо',
                en: 'Restart quiz',
                ru: 'Начать квиз заново',
              ),
        onPressed: mistakeTags.isNotEmpty
            ? provider.reviewMistakesAgain
            : provider.restartFull,
        variant: AppButtonVariant.outlined,
      ),
      tertiaryLabel: context.tr(
        ky: 'Практикага кайтуу',
        en: 'Back to practice',
        ru: 'Вернуться к практике',
      ),
      onTertiaryTap: () => context.go('/practice'),
    );
  }

  String _headline(BuildContext context, int accuracy) {
    if (provider.reviewSucceeded && accuracy >= 80) {
      return context.tr(
        ky: 'Жакшы текшерүү болду',
        en: 'Strong check',
        ru: 'Хорошая проверка',
      );
    }
    if (accuracy >= 60) {
      return context.tr(
        ky: 'Негизги темп жакшы',
        en: 'Core pace looks good',
        ru: 'Базовый темп хороший',
      );
    }
    return context.tr(
      ky: 'Дагы бир айлампа жардам берет',
      en: 'One more round will help',
      ru: 'Ещё один круг поможет',
    );
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
            isCorrect
                ? context.tr(
                    ky: 'Туура жооп',
                    en: 'Correct answer',
                    ru: 'Правильный ответ',
                  )
                : context.tr(
                    ky: 'Жооп түшүндүрмөсү',
                    en: 'Answer explanation',
                    ru: 'Пояснение ответа',
                  ),
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCorrect
                ? context.tr(
                    ky: 'Сиз туура вариантты тандадыңыз: $correct',
                    en: 'You chose the correct option: $correct',
                    ru: 'Вы выбрали правильный вариант: $correct',
                  )
                : context.tr(
                    ky: 'Сиз тандадыңыз: ${selected ?? 'жооп жок'}',
                    en: 'You selected: ${selected ?? 'no answer'}',
                    ru: 'Вы выбрали: ${selected ?? 'нет ответа'}',
                  ),
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              context.tr(
                ky: 'Туурасы: $correct',
                en: 'Correct: $correct',
                ru: 'Правильно: $correct',
              ),
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
