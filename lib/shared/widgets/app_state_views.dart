import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';
import 'app_button.dart';
import 'app_card.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.title = 'Жүктөлүүдө',
    this.message = 'Маалымат даярдалып жатат.',
    this.foregroundColor,
    this.indicatorColor,
  });

  final String title;
  final String message;
  final Color? foregroundColor;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? AppColors.textDark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: indicatorColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.title.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: color.withValues(alpha: 0.72),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.foregroundColor,
    this.buttonVariant = AppButtonVariant.primary,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? foregroundColor;
  final AppButtonVariant buttonVariant;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? AppColors.textDark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.title.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: color.withValues(alpha: 0.72),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              AppButton(
                variant: buttonVariant,
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Маалымат жүктөлгөн жок',
    required this.message,
    this.actionLabel = 'Кайра аракет кылуу',
    this.onAction,
    this.foregroundColor,
    this.buttonVariant = AppButtonVariant.primary,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final Color? foregroundColor;
  final AppButtonVariant buttonVariant;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? AppColors.textDark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.cloud_off, color: AppColors.accent, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.title.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: color.withValues(alpha: 0.72),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              AppButton(
                variant: buttonVariant,
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppSyncBanner extends StatelessWidget {
  const AppSyncBanner({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: accentColor.withValues(alpha: 0.08),
      borderColor: accentColor.withValues(alpha: 0.22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.14),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message, style: AppTextStyles.muted),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.outlined,
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
