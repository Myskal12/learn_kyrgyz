import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/sentence_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../providers/sentence_builder_provider.dart';

class SentenceBuilderScreen extends ConsumerStatefulWidget {
  const SentenceBuilderScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<SentenceBuilderScreen> createState() =>
      _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState
    extends ConsumerState<SentenceBuilderScreen> {
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
      ref.read(sentenceBuilderProvider).load(
            widget.categoryId,
            direction: direction,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(sentenceBuilderProvider);
    final direction = ref.watch(learningDirectionProvider);

    return AppShell(
      title: 'Сүйлөм түзүү',
      subtitle: 'Сүйлөмдөрдү түзүү',
      activeTab: AppTab.learn,
      child: Builder(
        builder: (context) {
          if (_lastDirection != direction) {
            _lastDirection = direction;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ref.read(sentenceBuilderProvider).setDirection(direction);
            });
          }
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.isCompleted) {
            return _SentenceBuilderSummary(provider: provider);
          }
          final sentence = provider.current;
          if (sentence == null) {
            return _EmptyState(
              onReload: () => provider.load(
                widget.categoryId,
                direction: direction,
              ),
            );
          }
          final isEnToKy = direction == LearningDirection.enToKy;
          final prompt = isEnToKy ? sentence.en : sentence.ky;

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
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Котормосу:', style: AppTextStyles.muted),
                    const SizedBox(height: 12),
                    _PromptChips(prompt: prompt),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Сиздин сүйлөмүңүз:',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.availableTokens.map((token) {
                  final isUsed = provider.selectedTokens
                      .any((selected) => selected.id == token.id);
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
                  direction: direction,
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.outlined,
                      onPressed: provider.canReset
                          ? provider.resetSelection
                          : null,
                      child: const Text('Кайра'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      onPressed: provider.answered
                          ? provider.next
                          : (provider.canCheck ? provider.check : null),
                      child: Text(
                        provider.answered
                            ? (provider.isLast ? 'Бүтөрүү' : 'Кийинки')
                            : (provider.canCheck ? 'Текшерүү' : 'Тандаңыз'),
                      ),
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
            Text(
              'Сүйлөм $current / $total',
              style: AppTextStyles.muted,
            ),
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
    final targetText =
        direction == LearningDirection.enToKy ? sentence.ky : sentence.en;
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
                Text(
                  'Туура жооп: $targetText',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SentenceBuilderSummary extends StatelessWidget {
  const _SentenceBuilderSummary({required this.provider});

  final SentenceBuilderProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Сессия аяктады', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Сүйлөмдөр',
                  value: provider.totalSentences.toString(),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Туура',
                  value: provider.correctCount.toString(),
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Ката',
                  value: provider.wrongCount.toString(),
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (provider.mistakes.isNotEmpty) ...[
            Text('Ката сүйлөмдөр', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.mistakes
                  .map(
                    (sentence) => AppChip(
                      label: '${sentence.en} - ${sentence.ky}',
                      variant: AppChipVariant.defaultChip,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          AppButton(
            fullWidth: true,
            onPressed: provider.restart,
            child: const Text('Кайра баштоо'),
          ),
          const SizedBox(height: 12),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.outlined,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Артка кайтуу'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(
          value,
          style: AppTextStyles.title.copyWith(color: color),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Бул категорияда сүйлөмдөр табылган жок.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppButton(
              onPressed: onReload,
              child: const Text('Кайра жүктөө'),
            ),
          ],
        ),
      ),
    );
  }
}
