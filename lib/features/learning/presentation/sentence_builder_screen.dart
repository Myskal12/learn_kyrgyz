import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/sentence_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/learning_direction_nav_button.dart';
import '../../../shared/widgets/session_summary_panel.dart';
import '../providers/sentence_builder_provider.dart';

class SentenceBuilderScreen extends ConsumerStatefulWidget {
  const SentenceBuilderScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<SentenceBuilderScreen> createState() =>
      _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends ConsumerState<SentenceBuilderScreen> {
  late final ProviderSubscription<LearningDirection> _directionSubscription;

  @override
  void initState() {
    super.initState();
    _directionSubscription = ref.listenManual<LearningDirection>(
      learningDirectionProvider,
      (previous, next) {
        if (previous == next) return;
        ref.read(sentenceBuilderProvider).setDirection(next);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final direction = ref.read(learningDirectionProvider);
      if (widget.categoryId.isNotEmpty) {
        ref.read(learningSessionProvider).setLastCategoryId(widget.categoryId);
      }
      ref
          .read(sentenceBuilderProvider)
          .load(widget.categoryId, direction: direction);
    });
  }

  @override
  void dispose() {
    _directionSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(sentenceBuilderProvider);
    final direction = ref.watch(learningDirectionProvider);

    return AppShell(
      title: context.tr(
        ky: 'Сүйлөм куруу',
        en: 'Sentence Builder',
        ru: 'Сборка предложений',
      ),
      subtitle: context.tr(
        ky: 'Сөздөрдү туура тартипке коюңуз',
        en: 'Build the right order',
        ru: 'Соберите правильный порядок',
      ),
      activeTab: AppTab.learn,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/practice',
      showBottomNav: false,
      topNavTrailing: const LearningDirectionNavButton(),
      topNavTrailingWidth: 108,
      child: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return AppLoadingState(
              title: context.tr(
                ky: 'Сүйлөмдөр жүктөлүүдө',
                en: 'Sentences are loading',
                ru: 'Предложения загружаются',
              ),
              message: context.tr(
                ky: 'Көнүгүү үчүн сүйлөмдөр даярдалып жатат.',
                en: 'Sentences for practice are being prepared.',
                ru: 'Подготавливаются предложения для практики.',
              ),
            );
          }
          if (provider.errorMessage != null) {
            return AppErrorState(
              message: provider.errorMessage!,
              onAction: () =>
                  provider.load(widget.categoryId, direction: direction),
            );
          }
          if (provider.isCompleted) {
            return _SentenceBuilderSummary(
              provider: provider,
              categoryId: widget.categoryId,
            );
          }

          final sentence = provider.current;
          if (sentence == null) {
            return AppEmptyState(
              title: context.tr(
                ky: 'Сүйлөмдөр табылган жок',
                en: 'No sentences found',
                ru: 'Предложения не найдены',
              ),
              message: context.tr(
                ky: 'Бул категория үчүн сүйлөмдөр табылган жок.',
                en: 'No sentences were found for this category.',
                ru: 'Для этой категории предложения не найдены.',
              ),
              icon: Icons.subject_outlined,
              actionLabel: context.tr(
                ky: 'Кайра жүктөө',
                en: 'Reload',
                ru: 'Перезагрузить',
              ),
              onAction: () =>
                  provider.load(widget.categoryId, direction: direction),
            );
          }

          final isEnToKy = direction == LearningDirection.enToKy;
          final prompt = isEnToKy ? sentence.en : sentence.ky;
          final target = isEnToKy ? sentence.ky : sentence.en;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            children: [
              _TopProgress(
                current: provider.index + 1,
                total: provider.totalSentences,
                progress: provider.progress,
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
                    color: AppColors.mutedSurface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    direction.helperTextOf(context),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.tr(
                  ky: 'Бул сүйлөмдү которуңуз',
                  en: 'Translate this sentence',
                  ru: 'Переведите это предложение',
                ),
                style: AppTextStyles.title.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(
                  ky: 'Сөздөрдү туура тартипте тандаңыз',
                  en: 'Tap words in the correct order',
                  ru: 'Нажмите слова в правильном порядке',
                ),
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              _PromptCard(prompt: prompt),
              const SizedBox(height: 12),
              _SelectedWordsDropZone(
                selected: provider.selectedTokens
                    .map((token) => token.text)
                    .toList(),
                onRemoveAt: provider.answered
                    ? null
                    : (index) =>
                          provider.removeToken(provider.selectedTokens[index]),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(ky: 'Сөз банкы', en: 'Word bank', ru: 'Банк слов'),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.availableTokens
                    .map(
                      (token) => AppChip(
                        label: token.text,
                        variant: AppChipVariant.defaultChip,
                        onTap: provider.answered
                            ? null
                            : () => provider.selectToken(token),
                      ),
                    )
                    .toList(),
              ),
              if (provider.answered) ...[
                const SizedBox(height: 12),
                _FeedbackPanel(
                  sentence: sentence,
                  target: target,
                  isCorrect: provider.lastCorrect,
                ),
                const SizedBox(height: 12),
                _BreakdownCard(sentence: sentence),
              ],
              const SizedBox(height: 14),
              if (!provider.answered)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.outlined,
                        onPressed: provider.canReset
                            ? provider.resetSelection
                            : null,
                        child: Text(
                          context.tr(
                            ky: 'Тазалоо',
                            en: 'Reset',
                            ru: 'Сбросить',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        onPressed: provider.canCheck ? provider.check : null,
                        child: Text(
                          context.tr(
                            ky: 'Текшерүү',
                            en: 'Check',
                            ru: 'Проверить',
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                AppButton(
                  fullWidth: true,
                  onPressed: provider.next,
                  child: Text(
                    provider.isLast
                        ? context.tr(
                            ky: 'Аяктоо',
                            en: 'Finish',
                            ru: 'Завершить',
                          )
                        : context.tr(
                            ky: 'Улантуу',
                            en: 'Continue',
                            ru: 'Продолжить',
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TopProgress extends StatelessWidget {
  const _TopProgress({
    required this.current,
    required this.total,
    required this.progress,
  });

  final int current;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.tr(
                ky: 'Сүйлөм $current / $total',
                en: 'Sentence $current / $total',
                ru: 'Предложение $current / $total',
              ),
              style: AppTextStyles.muted,
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.mutedSurface,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        prompt,
        style: AppTextStyles.title.copyWith(fontSize: 28),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SelectedWordsDropZone extends StatelessWidget {
  const _SelectedWordsDropZone({required this.selected, this.onRemoveAt});

  final List<String> selected;
  final void Function(int index)? onRemoveAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 84),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: selected.isEmpty
          ? Center(
              child: Text(
                context.tr(
                  ky: 'Төмөндөн сөздөрдү тандаңыз',
                  en: 'Select words below',
                  ru: 'Выберите слова ниже',
                ),
                style: AppTextStyles.muted,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected.asMap().entries.map((entry) {
                final index = entry.key;
                final token = entry.value;
                return AppChip(
                  label: token,
                  variant: AppChipVariant.primary,
                  onRemove: onRemoveAt == null
                      ? null
                      : () => onRemoveAt!(index),
                );
              }).toList(),
            ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.sentence,
    required this.target,
    required this.isCorrect,
  });

  final SentenceModel sentence;
  final String target;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect
                          ? context.tr(
                              ky: 'Эң сонун!',
                              en: 'Excellent!',
                              ru: 'Отлично!',
                            )
                          : context.tr(
                              ky: 'Азырынча туура эмес',
                              en: 'Not quite right',
                              ru: 'Пока не совсем верно',
                            ),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      isCorrect
                          ? context.tr(
                              ky: 'Котормонун тартиби мыкты.',
                              en: 'Perfect translation order.',
                              ru: 'Отличный порядок перевода.',
                            )
                          : context.tr(
                              ky: 'Төмөндөн туура сүйлөмдү караңыз.',
                              en: 'Review the correct sentence below.',
                              ru: 'Посмотрите правильный вариант ниже.',
                            ),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                target,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.sentence});

  final SentenceModel sentence;

  @override
  Widget build(BuildContext context) {
    final breakdown = <_BreakdownItem>[];
    if (sentence.highlight.trim().isNotEmpty) {
      breakdown.add(
        _BreakdownItem(
          label: sentence.highlight,
          value:
              '${sentence.wordEn.isEmpty ? '-' : sentence.wordEn} / ${sentence.wordKy.isEmpty ? '-' : sentence.wordKy}',
          hint: context.tr(
            ky: 'Негизги сөзгө фокус',
            en: 'Key word focus',
            ru: 'Фокус на ключевом слове',
          ),
        ),
      );
    }
    breakdown.add(
      _BreakdownItem(
        label: 'EN',
        value: sentence.en,
        hint: context.tr(
          ky: 'Баштапкы сүйлөм',
          en: 'Source sentence',
          ru: 'Исходное предложение',
        ),
      ),
    );
    breakdown.add(
      _BreakdownItem(
        label: 'KY',
        value: sentence.ky,
        hint: context.tr(
          ky: 'Максат сүйлөм',
          en: 'Target sentence',
          ru: 'Целевое предложение',
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              ky: 'Сүйлөм талдоосу',
              en: 'Sentence breakdown',
              ru: 'Разбор предложения',
            ),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...breakdown.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              padding: const EdgeInsets.only(bottom: 10),
              margin: EdgeInsets.only(
                bottom: index == breakdown.length - 1 ? 0 : 10,
              ),
              decoration: BoxDecoration(
                border: index == breakdown.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.label}: ${item.value}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(item.hint, style: AppTextStyles.caption),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  const _BreakdownItem({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;
}

class _SentenceBuilderSummary extends StatelessWidget {
  const _SentenceBuilderSummary({
    required this.provider,
    required this.categoryId,
  });

  final SentenceBuilderProvider provider;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final mistakes = provider.mistakes
        .take(6)
        .map((sentence) => '${sentence.en} -> ${sentence.ky}')
        .toList();
    final hasMistakes = mistakes.isNotEmpty;
    final reviewRoute = '/flashcards/$categoryId?mode=review';

    return SessionSummaryPanel(
      title: context.tr(
        ky: 'Сүйлөм куруу аяктады',
        en: 'Sentence builder complete',
        ru: 'Сборка предложений завершена',
      ),
      headline: _headline(context),
      message: hasMistakes
          ? context.tr(
              ky: 'Кээ бир сүйлөмдөрдү дагы кайталоо керек. Кыска кайталоо цикли тартипти эс тутумда тез бекемдейт.',
              en: 'Some sentences still need repetition. A short review cycle will quickly improve order recall.',
              ru: 'Некоторые предложения еще нужно повторить. Короткий цикл повторения быстро укрепит порядок слов в памяти.',
            )
          : context.tr(
              ky: 'Сүйлөм түзүмүн жакшы көзөмөлдөдүңүз. Эми башка контекстте бекемдөө үчүн квиз же карточкага өтүңүз.',
              en: 'Great structure control. Move to quiz or flashcards to reinforce in another context.',
              ru: 'Отличный контроль структуры. Перейдите к квизу или карточкам для закрепления в другом контексте.',
            ),
      metrics: [
        SessionSummaryMetric(
          label: context.tr(
            ky: 'Сүйлөмдөр',
            en: 'Sentences',
            ru: 'Предложения',
          ),
          value: provider.totalSentences.toString(),
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Туура', en: 'Correct', ru: 'Верно'),
          value: provider.correctCount.toString(),
          color: AppColors.success,
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Ката', en: 'Wrong', ru: 'Ошибки'),
          value: provider.wrongCount.toString(),
          color: AppColors.accent,
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Тактык', en: 'Accuracy', ru: 'Точность'),
          value: '${provider.accuracyPercent}%',
          color: AppColors.primary,
        ),
      ],
      noteTitle: context.tr(
        ky: 'Бул эмнеге маанилүү',
        en: 'Why this matters',
        ru: 'Почему это важно',
      ),
      noteMessage: context.tr(
        ky: 'Сүйлөмдөрдү толук тартипте куруу пассивдүү таануудан тышкары активдүү колдонуу жөндөмүн да өстүрөт.',
        en: 'Building full sentence order improves active production, not just passive recognition.',
        ru: 'Построение полного порядка слов развивает не только пассивное узнавание, но и активное использование.',
      ),
      tagsTitle: hasMistakes
          ? context.tr(
              ky: 'Кайра карай турган сүйлөмдөр',
              en: 'Sentences to revisit',
              ru: 'Предложения для повтора',
            )
          : null,
      tags: mistakes,
      primaryAction: SessionSummaryAction(
        label: hasMistakes
            ? context.tr(
                ky: 'Кайталоо кезегин ачуу',
                en: 'Open review queue',
                ru: 'Открыть очередь повторения',
              )
            : context.tr(
                ky: 'Квизге өтүү',
                en: 'Go to quiz',
                ru: 'Перейти к квизу',
              ),
        onPressed: hasMistakes
            ? () => context.go(reviewRoute)
            : () => context.go('/quiz/$categoryId'),
      ),
      secondaryAction: SessionSummaryAction(
        label: hasMistakes
            ? context.tr(
                ky: 'Каталарды кайра аткаруу',
                en: 'Retry mistakes',
                ru: 'Повторить ошибки',
              )
            : context.tr(
                ky: 'Карточкада машыгуу',
                en: 'Practice flashcards',
                ru: 'Практика с карточками',
              ),
        onPressed: hasMistakes
            ? provider.reviewMistakes
            : () => context.go('/flashcards/$categoryId'),
        variant: AppButtonVariant.outlined,
      ),
      tertiaryLabel: context.tr(
        ky: 'Практикага кайтуу',
        en: 'Back to practice',
        ru: 'Назад к практике',
      ),
      onTertiaryTap: () => context.go('/practice'),
    );
  }

  String _headline(BuildContext context) {
    if (provider.wrongCount == 0 && provider.correctCount > 0) {
      return context.tr(
        ky: 'Сонун котормо агымы',
        en: 'Excellent translation flow',
        ru: 'Отличный поток перевода',
      );
    }
    if (provider.accuracyPercent >= 70) {
      return context.tr(
        ky: 'Туруктуу прогресс',
        en: 'Solid progress',
        ru: 'Стабильный прогресс',
      );
    }
    return context.tr(
      ky: 'Дагы бир өтүү сунушталат',
      en: 'One more pass recommended',
      ru: 'Рекомендуется еще один проход',
    );
  }
}
