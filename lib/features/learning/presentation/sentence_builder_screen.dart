import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/sentence_model.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
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
  late final LearningDirection _direction;

  @override
  void initState() {
    super.initState();
    _direction = ref.read(learningDirectionProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId.isNotEmpty) {
        ref.read(learningSessionProvider).setLastCategoryId(widget.categoryId);
      }
      ref
          .read(sentenceBuilderProvider)
          .load(widget.categoryId, direction: _direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(sentenceBuilderProvider);

    return AppShell(
      title: 'Сүйлөм түзүү',
      subtitle: 'Сүйлөмдөрдү түзүү',
      activeTab: AppTab.learn,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/practice',
      showBottomNav: false,
      child: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const AppLoadingState(
              title: 'Сүйлөмдөр жүктөлүүдө',
              message: 'Көнүгүү үчүн сүйлөмдөр даярдалып жатат.',
            );
          }
          if (provider.errorMessage != null) {
            return AppErrorState(
              message: provider.errorMessage!,
              onAction: () =>
                  provider.load(widget.categoryId, direction: _direction),
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
            return _EmptyState(
              onReload: () =>
                  provider.load(widget.categoryId, direction: _direction),
            );
          }
          final isEnToKy = _direction == LearningDirection.enToKy;
          final prompt = isEnToKy ? sentence.en : sentence.ky;
          final promptLabel = isEnToKy
              ? 'Берилген англисче сүйлөм'
              : 'Берилген кыргызча сүйлөм';
          final answerLabel = isEnToKy
              ? 'Чогулта турган кыргызча сүйлөм'
              : 'Чогулта турган англисче сүйлөм';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Text(
                'Сүйлөм түзүү',
                style: AppTextStyles.heading.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Туура тартипте сөздөрдү жайгаштырыңыз',
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              _ProgressHeader(
                current: provider.index + 1,
                total: provider.totalSentences,
                progress: provider.progress,
              ),
              const SizedBox(height: 20),
              const _SentenceHintCard(),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(promptLabel, style: AppTextStyles.muted),
                    const SizedBox(height: 12),
                    _PromptChips(prompt: prompt),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                answerLabel,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: provider.selectedTokens.isEmpty
                    ? Center(
                        child: Text(
                          'Сөздөрдү тандаңыз...',
                          style: AppTextStyles.muted,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.selectedTokens
                            .map(
                              (token) => AppChip(
                                label: token.text,
                                variant: AppChipVariant.primary,
                                onRemove: provider.answered
                                    ? null
                                    : () => provider.removeToken(token),
                              ),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                'Сөздөр банкы:',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.availableTokens.map((token) {
                  final isUsed = provider.selectedTokens.any(
                    (selected) => selected.id == token.id,
                  );
                  return Opacity(
                    opacity: isUsed ? 0.3 : 1,
                    child: AppChip(
                      label: token.text,
                      variant: AppChipVariant.defaultChip,
                      onTap: provider.answered || isUsed
                          ? null
                          : () => provider.selectToken(token),
                    ),
                  );
                }).toList(),
              ),
              if (provider.answered) ...[
                const SizedBox(height: 16),
                _ResultCard(
                  sentence: sentence,
                  isCorrect: provider.lastCorrect,
                  direction: _direction,
                ),
              ],
              const SizedBox(height: 20),
              AdaptivePanelGrid(
                maxColumns: 2,
                minItemWidth: 150,
                children: [
                  AppButton(
                    variant: AppButtonVariant.outlined,
                    onPressed: provider.canReset
                        ? provider.resetSelection
                        : null,
                    child: const Text('Кайра'),
                  ),
                  AppButton(
                    onPressed: provider.answered
                        ? provider.next
                        : (provider.canCheck ? provider.check : null),
                    child: Text(
                      provider.answered
                          ? (provider.isLast ? 'Бүтөрүү' : 'Кийинки')
                          : (provider.canCheck ? 'Текшерүү' : 'Тандаңыз'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
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
            Text('Сүйлөм $current / $total', style: AppTextStyles.muted),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ProgressBar(value: progress),
      ],
    );
  }
}

class _PromptChips extends StatelessWidget {
  const _PromptChips({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    final words = prompt.split(' ');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;
        final variant = index == 0
            ? AppChipVariant.accent
            : index == 2
            ? AppChipVariant.primary
            : AppChipVariant.defaultChip;
        return AppChip(label: word, variant: variant);
      }).toList(),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, const Color(0xFFF7C15C)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.sentence,
    required this.isCorrect,
    required this.direction,
  });

  final SentenceModel sentence;
  final bool isCorrect;
  final LearningDirection direction;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.accent;
    final targetText = direction == LearningDirection.enToKy
        ? sentence.ky
        : sentence.en;
    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: color.withValues(alpha: 0.1),
      borderColor: color.withValues(alpha: 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Туура!' : 'Туура эмес',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Туура жооп: $targetText', style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
        .map((sentence) => '${sentence.en} → ${sentence.ky}')
        .toList();
    final hasMistakes = mistakes.isNotEmpty;
    final reviewRoute = '/flashcards/$categoryId?mode=review';

    return SessionSummaryPanel(
      title: 'Сүйлөм түзүү аяктады',
      headline: _headline(),
      message: hasMistakes
          ? 'Алсыз сүйлөмдөр review queue болуп белгиленди. Адегенде ошол сөздөрдү жаап, андан соң квиз менен текшерсеңиз жакшы болот.'
          : 'Тартипти жакшы кармадыңыз. Эми ушул эле теманы квиз менен же карточка менен бекемдеңиз.',
      metrics: [
        SessionSummaryMetric(
          label: 'Сүйлөмдөр',
          value: provider.totalSentences.toString(),
        ),
        SessionSummaryMetric(
          label: 'Туура',
          value: provider.correctCount.toString(),
          color: AppColors.success,
        ),
        SessionSummaryMetric(
          label: 'Ката',
          value: provider.wrongCount.toString(),
          color: AppColors.accent,
        ),
        SessionSummaryMetric(
          label: 'Тактык',
          value: '${provider.accuracyPercent}%',
          color: AppColors.primary,
        ),
      ],
      noteTitle: 'Эмне үчүн бул маанилүү',
      noteMessage:
          'Сүйлөмдү өзүңүз чогултуу сөздөрдү жөн гана таанууга эмес, активдүү колдонууга өткөрөт.',
      tagsTitle: hasMistakes ? 'Кайра түзө турган сүйлөмдөр' : null,
      tags: mistakes,
      primaryAction: SessionSummaryAction(
        label: hasMistakes ? 'Кайталоо кезегине өтүү' : 'Квизге өтүү',
        onPressed: hasMistakes
            ? () => context.go(reviewRoute)
            : () => context.go('/quiz/$categoryId'),
      ),
      secondaryAction: SessionSummaryAction(
        label: hasMistakes
            ? 'Ката сүйлөмдөрдү кайра өтүү'
            : 'Карточкалар менен бекемдөө',
        onPressed: hasMistakes
            ? provider.reviewMistakes
            : () => context.go('/flashcards/$categoryId'),
        variant: AppButtonVariant.outlined,
      ),
      tertiaryLabel: 'Практикага кайтуу',
      onTertiaryTap: () => context.go('/practice'),
    );
  }

  String _headline() {
    if (provider.wrongCount == 0 && provider.correctCount > 0) {
      return 'Сүйлөмдөр так чыкты';
    }
    if (provider.accuracyPercent >= 70) {
      return 'Жакшы курулуш';
    }
    return 'Бир аз дагы бекемдөө керек';
  }
}

class _SentenceHintCard extends StatelessWidget {
  const _SentenceHintCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
      borderColor: AppColors.primary.withValues(alpha: 0.18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Алгач маанини окуңуз, анан сөздөрдү башынан аягына чейин чогултуңуз. Туура жооп тек гана түстөр менен эмес, текст менен да көрсөтүлөт.',
              style: AppTextStyles.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'Сүйлөмдөр табылган жок',
      message: 'Бул категория үчүн сүйлөмдөр Firebase же кэштен табылган жок.',
      icon: Icons.subject_outlined,
      actionLabel: 'Кайра жүктөө',
      onAction: onReload,
    );
  }
}
