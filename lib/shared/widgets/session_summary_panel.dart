import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'app_chip.dart';

class SessionSummaryMetric {
  const SessionSummaryMetric({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;
}

class SessionSummaryAction {
  const SessionSummaryAction({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
}

class SessionSummaryPanel extends StatelessWidget {
  const SessionSummaryPanel({
    super.key,
    required this.title,
    required this.headline,
    required this.message,
    required this.metrics,
    required this.primaryAction,
    this.secondaryAction,
    this.tertiaryLabel,
    this.onTertiaryTap,
    this.tags = const [],
    this.tagsTitle,
    this.noteTitle,
    this.noteMessage,
  });

  final String title;
  final String headline;
  final String message;
  final List<SessionSummaryMetric> metrics;
  final SessionSummaryAction primaryAction;
  final SessionSummaryAction? secondaryAction;
  final String? tertiaryLabel;
  final VoidCallback? onTertiaryTap;
  final List<String> tags;
  final String? tagsTitle;
  final String? noteTitle;
  final String? noteMessage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        AppCard(
          gradient: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(
                headline,
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: metrics
                .map((metric) => _MetricTile(metric: metric))
                .toList(),
          ),
        ),
        if (noteTitle != null && noteMessage != null) ...[
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: AppColors.primary.withValues(alpha: 0.06),
            borderColor: AppColors.primary.withValues(alpha: 0.18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noteTitle!,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(noteMessage!, style: AppTextStyles.muted),
              ],
            ),
          ),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tagsTitle != null) ...[
                  Text(
                    tagsTitle!,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map(
                        (tag) => AppChip(
                          label: tag,
                          variant: AppChipVariant.defaultChip,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        AppButton(
          fullWidth: true,
          variant: primaryAction.variant,
          onPressed: primaryAction.onPressed,
          child: Text(primaryAction.label),
        ),
        if (secondaryAction != null) ...[
          const SizedBox(height: 12),
          AppButton(
            fullWidth: true,
            variant: secondaryAction!.variant,
            onPressed: secondaryAction!.onPressed,
            child: Text(secondaryAction!.label),
          ),
        ],
        if (tertiaryLabel != null && onTertiaryTap != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onTertiaryTap,
            child: Text(
              tertiaryLabel!,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final SessionSummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = metric.color ?? AppColors.textDark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            metric.value,
            style: AppTextStyles.title.copyWith(fontSize: 22, color: color),
          ),
          const SizedBox(height: 4),
          Text(metric.label, style: AppTextStyles.muted),
        ],
      ),
    );
  }
}
