import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/learning_direction_nav_button.dart';
import '../../profile/providers/progress_provider.dart';
import '../providers/categories_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({
    super.key,
    this.showAppBar = true,
    this.homeMode = false,
  });

  final bool showAppBar;
  final bool homeMode;

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider).load();
      ref.read(progressProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final progress = ref.watch(progressProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);
    final categories = categoriesState.categories;

    if (categoriesState.isLoading && categories.isEmpty) {
      return AppShell(
        title: _shellTitle(context),
        subtitle: _shellSubtitle(context),
        activeTab: AppTab.learn,
        showTopNav: widget.showAppBar,
        topNavTrailing: const LearningDirectionNavButton(),
        topNavTrailingWidth: 108,
        child: AppLoadingState(
          title: context.tr(
            ky: 'Сабактар жүктөлүүдө',
            en: 'Lessons are loading',
            ru: 'Уроки загружаются',
          ),
          message: context.tr(
            ky: 'Жол картасы даярдалып жатат.',
            en: 'The roadmap is being prepared.',
            ru: 'Дорожная карта подготавливается.',
          ),
        ),
      );
    }

    if (categoriesState.errorMessage != null && categories.isEmpty) {
      return AppShell(
        title: _shellTitle(context),
        subtitle: _shellSubtitle(context),
        activeTab: AppTab.learn,
        showTopNav: widget.showAppBar,
        topNavTrailing: const LearningDirectionNavButton(),
        topNavTrailingWidth: 108,
        child: AppErrorState(
          message: categoriesState.errorMessage!,
          onAction: () => ref.read(categoriesProvider).load(force: true),
        ),
      );
    }

    if (categories.isEmpty) {
      return AppShell(
        title: _shellTitle(context),
        subtitle: _shellSubtitle(context),
        activeTab: AppTab.learn,
        showTopNav: widget.showAppBar,
        topNavTrailing: const LearningDirectionNavButton(),
        topNavTrailingWidth: 108,
        child: AppEmptyState(
          title: context.tr(
            ky: 'Сабактар табылган жок',
            en: 'No lessons found',
            ru: 'Уроки не найдены',
          ),
          message: context.tr(
            ky: 'Азырынча категория жок.',
            en: 'No categories available yet.',
            ru: 'Категории пока недоступны.',
          ),
          icon: Icons.map_outlined,
          actionLabel: context.tr(
            ky: 'Кайра жүктөө',
            en: 'Reload',
            ru: 'Обновить',
          ),
          onAction: () => ref.read(categoriesProvider).load(force: true),
        ),
      );
    }

    final steps = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final words = wordsRepo.getCachedWords(category.id);
      final completion = progress.completionForCategory(words);
      final unlockTarget = index * 5;
      final locked = index > 0 && progress.totalWordsMastered < unlockTarget;
      final isCompleted = completion >= 0.95;
      final isActive = !locked && completion > 0 && completion < 0.95;
      final status = locked
          ? _JourneyStepStatus.locked
          : isCompleted
          ? _JourneyStepStatus.completed
          : isActive
          ? _JourneyStepStatus.active
          : _JourneyStepStatus.unlocked;

      return _JourneyStep(
        category: category,
        index: index,
        wordsCount: words.length,
        completion: completion,
        reviewDue: progress.reviewDueForCategory(words),
        status: status,
      );
    }).toList();

    final completedCount = steps
        .where((step) => step.status == _JourneyStepStatus.completed)
        .length;
    final totalReviewDue = steps.fold<int>(
      0,
      (sum, step) => sum + step.reviewDue,
    );
    final primaryStep = _resolvePrimaryStep(steps);

    return AppShell(
      title: _shellTitle(context),
      subtitle: _shellSubtitle(context),
      activeTab: AppTab.learn,
      showTopNav: widget.showAppBar,
      topNavTrailing: const LearningDirectionNavButton(),
      topNavTrailingWidth: 108,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          Text(
            context.tr(ky: 'Сиздин жол', en: 'Your journey', ru: 'Ваш путь'),
            style: AppTextStyles.heading.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr(
              ky: 'Ар бир теманы бүтүрүп, кийинкисин ачыңыз.',
              en: 'Complete each lesson to unlock the next one.',
              ru: 'Завершайте уроки, чтобы открыть следующие.',
            ),
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          _OverallProgressCard(
            completedCount: completedCount,
            totalCount: steps.length,
            reviewDue: totalReviewDue,
            onContinue: primaryStep == null
                ? () => context.push('/practice')
                : () => context.push('/flashcards/${primaryStep.category.id}'),
          ),
          const SizedBox(height: 14),
          Stack(
            children: [
              Positioned(
                left: 18,
                top: 12,
                bottom: 20,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Column(
                children: steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return _JourneyStepTile(
                    step: step,
                    isLast: index == steps.length - 1,
                    onTap: step.status == _JourneyStepStatus.locked
                        ? null
                        : () => context.push('/flashcards/${step.category.id}'),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _JourneyStep? _resolvePrimaryStep(List<_JourneyStep> steps) {
    for (final step in steps) {
      if (step.status == _JourneyStepStatus.active) {
        return step;
      }
    }
    for (final step in steps) {
      if (step.status == _JourneyStepStatus.unlocked) {
        return step;
      }
    }
    return null;
  }

  String _shellTitle(BuildContext context) {
    if (widget.homeMode) {
      return context.tr(ky: 'Башкы', en: 'Home', ru: 'Главная');
    }
    return context.tr(ky: 'Жол картасы', en: 'Roadmap', ru: 'Дорожная карта');
  }

  String _shellSubtitle(BuildContext context) {
    return context.tr(
      ky: 'Саякатыңыздын баскычтары',
      en: 'Your journey steps',
      ru: 'Шаги вашего пути',
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({
    required this.completedCount,
    required this.totalCount,
    required this.reviewDue,
    required this.onContinue,
  });

  final int completedCount;
  final int totalCount;
  final int reviewDue;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr(
                  ky: 'Жалпы прогресс',
                  en: 'Overall progress',
                  ru: 'Общий прогресс',
                ),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '$completedCount/$totalCount',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.mutedSurface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricPill(
                label: context.tr(
                  ky: '$reviewDue кайталоо даяр',
                  en: '$reviewDue reviews due',
                  ru: '$reviewDue готовы к повторению',
                ),
              ),
              _MetricPill(
                label: context.tr(
                  ky: '${(progress * 100).round()}% бүттү',
                  en: '${(progress * 100).round()}% complete',
                  ru: '${(progress * 100).round()}% завершено',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(
            fullWidth: true,
            onPressed: onContinue,
            child: Text(
              context.tr(
                ky: 'Жолду улантуу',
                en: 'Continue journey',
                ru: 'Продолжить путь',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStepTile extends StatelessWidget {
  const _JourneyStepTile({
    required this.step,
    required this.isLast,
    this.onTap,
  });

  final _JourneyStep step;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusConfig = _statusConfig(context, step.status);
    final xOffset = _offsetForIndex(step.index);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                _StatusNode(
                  background: statusConfig.nodeBackground,
                  borderColor: statusConfig.nodeBorder,
                  icon: statusConfig.icon,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Transform.translate(
              offset: Offset(xOffset, 0),
              child: Opacity(
                opacity: step.status == _JourneyStepStatus.locked ? 0.7 : 1,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusConfig.cardBorder,
                          width: step.status == _JourneyStepStatus.active
                              ? 2
                              : 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusConfig.shadow,
                            blurRadius: step.status == _JourneyStepStatus.active
                                ? 16
                                : 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.category.title,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.tr(
                                        ky: '${step.wordsCount} сөз · ${statusConfig.label}',
                                        en: '${step.wordsCount} words · ${statusConfig.label}',
                                        ru: '${step.wordsCount} слов · ${statusConfig.label}',
                                      ),
                                      style: AppTextStyles.caption.copyWith(
                                        color: statusConfig.captionColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.mutedSurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${step.index + 1}',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (step.status != _JourneyStepStatus.locked) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: step.completion,
                                minHeight: 7,
                                backgroundColor: AppColors.mutedSurface,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  step.status == _JourneyStepStatus.completed
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _offsetForIndex(int index) {
    switch (index % 3) {
      case 1:
        return 8;
      case 2:
        return -8;
      default:
        return 0;
    }
  }

  _StepVisualConfig _statusConfig(
    BuildContext context,
    _JourneyStepStatus status,
  ) {
    switch (status) {
      case _JourneyStepStatus.completed:
        return _StepVisualConfig(
          label: context.tr(ky: 'Бүттү', en: 'Completed', ru: 'Завершено'),
          icon: const Icon(Icons.check, size: 18, color: Colors.white),
          nodeBackground: AppColors.success,
          nodeBorder: Colors.transparent,
          cardBorder: AppColors.success.withValues(alpha: 0.35),
          captionColor: AppColors.success,
          shadow: AppColors.success.withValues(alpha: 0.16),
        );
      case _JourneyStepStatus.active:
        return _StepVisualConfig(
          label: context.tr(ky: 'Учурдагы', en: 'Current', ru: 'Текущий'),
          icon: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          nodeBackground: AppColors.primary,
          nodeBorder: AppColors.primary.withValues(alpha: 0.15),
          cardBorder: AppColors.primary,
          captionColor: AppColors.primary,
          shadow: AppColors.primary.withValues(alpha: 0.18),
        );
      case _JourneyStepStatus.unlocked:
        return _StepVisualConfig(
          label: context.tr(ky: 'Ачык', en: 'Open', ru: 'Открыто'),
          icon: Icon(Icons.circle_outlined, size: 16, color: AppColors.primary),
          nodeBackground: AppColors.surface,
          nodeBorder: AppColors.primary.withValues(alpha: 0.32),
          cardBorder: AppColors.border,
          captionColor: AppColors.muted,
          shadow: Colors.black.withValues(alpha: 0.06),
        );
      case _JourneyStepStatus.locked:
        return _StepVisualConfig(
          label: context.tr(ky: 'Кулпуланган', en: 'Locked', ru: 'Закрыто'),
          icon: Icon(Icons.lock, size: 14, color: AppColors.muted),
          nodeBackground: AppColors.mutedSurface,
          nodeBorder: Colors.transparent,
          cardBorder: AppColors.border,
          captionColor: AppColors.muted,
          shadow: Colors.black.withValues(alpha: 0.04),
        );
    }
  }
}

class _StatusNode extends StatelessWidget {
  const _StatusNode({
    required this.background,
    required this.borderColor,
    required this.icon,
  });

  final Color background;
  final Color borderColor;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderColor == Colors.transparent ? 0 : 2,
        ),
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StepVisualConfig {
  const _StepVisualConfig({
    required this.label,
    required this.icon,
    required this.nodeBackground,
    required this.nodeBorder,
    required this.cardBorder,
    required this.captionColor,
    required this.shadow,
  });

  final String label;
  final Widget icon;
  final Color nodeBackground;
  final Color nodeBorder;
  final Color cardBorder;
  final Color captionColor;
  final Color shadow;
}

enum _JourneyStepStatus { completed, active, unlocked, locked }

class _JourneyStep {
  const _JourneyStep({
    required this.category,
    required this.index,
    required this.wordsCount,
    required this.completion,
    required this.reviewDue,
    required this.status,
  });

  final CategoryModel category;
  final int index;
  final int wordsCount;
  final double completion;
  final int reviewDue;
  final _JourneyStepStatus status;
}
