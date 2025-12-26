import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/learning_session_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/sentence_model.dart';
import '../providers/sentence_builder_provider.dart';

class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
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
      context.read<SentenceBuilderProvider>().load(
            widget.categoryId,
            direction: direction,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sentence Builder')),
      body: SafeArea(
        child: Consumer<SentenceBuilderProvider>(
          builder: (context, provider, _) {
            final direction = context.watch<SettingsProvider>().direction;
            if (_lastDirection != direction) {
              _lastDirection = direction;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context.read<SentenceBuilderProvider>().setDirection(direction);
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
            final targetLabel = isEnToKy
                ? 'Build the Kyrgyz sentence'
                : 'Build the English sentence';

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sentence ${provider.index + 1}/${provider.totalSentences}',
                        style: AppTextStyles.body,
                      ),
                      const Spacer(),
                      Text(
                        '${(provider.progress * 100).round()}%',
                        style: AppTextStyles.title,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: provider.progress,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            prompt,
                            style: AppTextStyles.heading.copyWith(fontSize: 28),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 12),
                          _HighlightChips(sentence: sentence),
                          const SizedBox(height: 16),
                          Text(
                            targetLabel,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _TokenSection(
                            title: 'Your sentence',
                            emptyLabel: 'Tap words below to build it.',
                            tokens: provider.selectedTokens,
                            enabled: !provider.answered,
                            onTap: provider.removeToken,
                            showRemove: true,
                          ),
                          const SizedBox(height: 16),
                          _TokenSection(
                            title: 'Word bank',
                            emptyLabel: 'All words are used.',
                            tokens: provider.availableTokens,
                            enabled: !provider.answered,
                            onTap: provider.selectToken,
                            showRemove: false,
                          ),
                          if (provider.answered) ...[
                            const SizedBox(height: 16),
                            _ResultCard(
                              sentence: sentence,
                              isCorrect: provider.lastCorrect,
                              direction: direction,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.canReset
                              ? provider.resetSelection
                              : null,
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: provider.answered
                              ? provider.next
                              : (provider.canCheck ? provider.check : null),
                          child: Text(
                            provider.answered
                                ? (provider.isLast ? 'Finish' : 'Next')
                                : (provider.canCheck
                                    ? 'Check'
                                    : 'Select all words'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HighlightChips extends StatelessWidget {
  const _HighlightChips({required this.sentence});

  final SentenceModel sentence;

  @override
  Widget build(BuildContext context) {
    final highlightEn = sentence.highlight.trim().isNotEmpty
        ? sentence.highlight.trim()
        : sentence.wordEn.trim();
    final highlightKy = sentence.wordKy.trim();
    if (highlightEn.isEmpty && highlightKy.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (highlightEn.isNotEmpty)
          _HighlightChip(label: highlightEn, color: AppColors.accent),
        if (highlightKy.isNotEmpty)
          _HighlightChip(label: highlightKy, color: AppColors.primary),
      ],
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}

class _TokenSection extends StatelessWidget {
  const _TokenSection({
    required this.title,
    required this.emptyLabel,
    required this.tokens,
    required this.enabled,
    required this.onTap,
    required this.showRemove,
  });

  final String title;
  final String emptyLabel;
  final List<SentenceToken> tokens;
  final bool enabled;
  final ValueChanged<SentenceToken> onTap;
  final bool showRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: 12),
          if (tokens.isEmpty)
            Text(emptyLabel, style: AppTextStyles.muted)
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: tokens.map((token) {
                if (showRemove) {
                  return InputChip(
                    label: Text(token.text),
                    onDeleted: enabled ? () => onTap(token) : null,
                    deleteIcon: const Icon(Icons.close),
                  );
                }
                return ActionChip(
                  label: Text(token.text),
                  onPressed: enabled ? () => onTap(token) : null,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
        ],
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
    final color = isCorrect ? AppColors.success : AppColors.error;
    final status = isCorrect ? 'Correct!' : 'Not quite.';
    final targetText =
        direction == LearningDirection.enToKy ? sentence.ky : sentence.en;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(status, style: AppTextStyles.title.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Correct sentence', style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Text(targetText, style: AppTextStyles.body),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session complete', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                  label: 'Sentences',
                  value: provider.totalSentences.toString(),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Correct',
                  value: provider.correctCount.toString(),
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Incorrect',
                  value: provider.wrongCount.toString(),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (provider.mistakes.isNotEmpty) ...[
            Text('Mistakes', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.mistakes
                  .map(
                    (sentence) =>
                        Chip(label: Text('${sentence.en} - ${sentence.ky}')),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: provider.restart,
            child: const Text('Restart'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back'),
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
        Text(value, style: AppTextStyles.title.copyWith(color: color)),
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
              'No sentences available for this category.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onReload,
              child: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }
}
