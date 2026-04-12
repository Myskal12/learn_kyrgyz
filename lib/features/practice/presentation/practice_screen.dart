import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../categories/providers/categories_provider.dart';
import '../../profile/providers/progress_provider.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  _PracticeGoal? _selectedGoal;
  _PracticeMode? _selectedMode;
  String? _selectedCategoryId;
  int _currentStep = 0;

  static const List<String> _stepTitles = ['Максат', 'Формат', 'Тема', 'Старт'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider).load();
      ref.read(progressProvider).load();
      ref.read(learningSessionProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final progress = ref.watch(progressProvider);
    final onboarding = ref.watch(onboardingProvider);
    final session = ref.watch(learningSessionProvider);
    final wordsRepo = ref.read(wordsRepositoryProvider);

    final categories = categoriesState.categories;
    final snapshots = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final words = wordsRepo.getCachedWords(category.id);
      final mastered = progress.masteredWordsForCategory(words);
      final seen = progress.seenWordsForCategory(words);
      final reviewDue = progress.reviewDueForCategory(words);
      final completion = progress.completionForCategory(words);
      final unlockThreshold = index * 5;
      final locked = index > 0 && progress.totalWordsMastered < unlockThreshold;
      return _CategorySnapshot(
        category: category,
        mastered: mastered,
        seen: seen,
        reviewDue: reviewDue,
        completion: completion,
        locked: locked,
      );
    }).toList();

    final continueSnapshot = _resolveContinueSnapshot(
      snapshots,
      session.lastCategoryId,
    );
    final reviewSnapshot = snapshots
        .where((item) => !item.locked && item.reviewDue > 0)
        .fold<_CategorySnapshot?>(null, (best, item) {
          if (best == null) return item;
          if (item.reviewDue > best.reviewDue) return item;
          if (item.reviewDue == best.reviewDue &&
              item.completion < best.completion) {
            return item;
          }
          return best;
        });

    final defaultGoal = _defaultGoal(progress, reviewSnapshot);
    final activeGoal = _selectedGoal ?? defaultGoal;
    final modeOptions = _modeOptionsForGoal(activeGoal);
    final activeMode = modeOptions.contains(_selectedMode)
        ? _selectedMode!
        : _defaultModeForGoal(activeGoal);
    final topicOptions = _topicOptionsForGoal(
      goal: activeGoal,
      snapshots: snapshots,
      continueSnapshot: continueSnapshot,
      reviewSnapshot: reviewSnapshot,
    );
    final selectedSnapshot = _resolveSelectedSnapshot(
      topicOptions,
      _selectedCategoryId,
    );
    final totalReviewDue = snapshots.fold<int>(
      0,
      (sum, item) => sum + item.reviewDue,
    );
    final plan = _GuidedPracticePlan.fromSelection(
      goal: activeGoal,
      mode: activeMode,
      snapshot: selectedSnapshot,
      totalReviewDue: totalReviewDue,
      hasStarted: progress.totalWordsMastered > 0,
      dailyGoalMinutes: onboarding.dailyGoalMinutes,
    );

    Widget body;
    if (categoriesState.isLoading && categories.isEmpty) {
      body = const AppLoadingState(
        title: 'Практика даярдалып жатат',
        message: 'Категориялар жана агым тандагыч даярдалып жатат.',
      );
    } else if (categoriesState.errorMessage != null && categories.isEmpty) {
      body = AppErrorState(
        message: categoriesState.errorMessage!,
        onAction: () => ref.read(categoriesProvider).load(force: true),
      );
    } else if (categories.isEmpty) {
      body = AppEmptyState(
        title: 'Практика үчүн темалар жок',
        message: 'Категориялар табылмайынча машыгуу агымын түзө албайбыз.',
        icon: Icons.extension_outlined,
        actionLabel: 'Кайра жүктөө',
        onAction: () => ref.read(categoriesProvider).load(force: true),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text('Практика', style: AppTextStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'Бир экранда бир гана тандоо: ошентип багыт табуу жеңилирээк.',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          _WaterfallProgress(currentStep: _currentStep, titles: _stepTitles),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child: _buildWaterfallStep(
                context: context,
                step: _currentStep,
                activeGoal: activeGoal,
                activeMode: activeMode,
                modeOptions: modeOptions,
                topicOptions: topicOptions,
                selectedSnapshot: selectedSnapshot,
                progress: progress,
                continueSnapshot: continueSnapshot,
                reviewSnapshot: reviewSnapshot,
                totalReviewDue: totalReviewDue,
                plan: plan,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _WaterfallActions(
            currentStep: _currentStep,
            totalSteps: _stepTitles.length,
            nextLabel: _nextLabelForStep(_currentStep),
            onBack: () => _goBack(context),
            onNext: _goNext,
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(context);
      },
      child: AppShell(
        title: 'Практика',
        subtitle: 'Waterfall агым менен тандаңыз',
        activeTab: AppTab.practice,
        child: body,
      ),
    );
  }

  Widget _buildWaterfallStep({
    required BuildContext context,
    required int step,
    required _PracticeGoal activeGoal,
    required _PracticeMode activeMode,
    required List<_PracticeMode> modeOptions,
    required List<_CategorySnapshot> topicOptions,
    required _CategorySnapshot selectedSnapshot,
    required ProgressProvider progress,
    required _CategorySnapshot continueSnapshot,
    required _CategorySnapshot? reviewSnapshot,
    required int totalReviewDue,
    required _GuidedPracticePlan plan,
  }) {
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeader(
              number: 1,
              title: 'Максат',
              subtitle: 'Адегенде бүгүнкү негизги максатты тактайбыз.',
            ),
            const SizedBox(height: 12),
            AdaptivePanelGrid(
              maxColumns: 1,
              minItemWidth: 260,
              spacing: 12,
              children:
                  _goalOptions(
                    progress: progress,
                    continueSnapshot: continueSnapshot,
                    reviewSnapshot: reviewSnapshot,
                    totalReviewDue: totalReviewDue,
                  ).map((option) {
                    return _SelectableFlowCard(
                      title: option.title,
                      subtitle: option.subtitle,
                      helper: option.helper,
                      icon: option.icon,
                      color: option.color,
                      selected: option.goal == activeGoal,
                      onTap: () {
                        setState(() {
                          _selectedGoal = option.goal;
                          _selectedMode = _defaultModeForGoal(option.goal);
                          _selectedCategoryId = _defaultCategoryIdForGoal(
                            goal: option.goal,
                            continueSnapshot: continueSnapshot,
                            reviewSnapshot: reviewSnapshot,
                            fallback: selectedSnapshot,
                          );
                          _currentStep = 1;
                        });
                      },
                    );
                  }).toList(),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeader(
              number: 2,
              title: 'Формат',
              subtitle: 'Эми ушул сессия үчүн бир форматты тандайбыз.',
            ),
            const SizedBox(height: 12),
            AdaptivePanelGrid(
              maxColumns: 1,
              minItemWidth: 240,
              spacing: 12,
              children: modeOptions.map((mode) {
                final details = _modeDetails(
                  mode,
                  reviewFocused: activeGoal == _PracticeGoal.review,
                );
                return _SelectableFlowCard(
                  title: details.title,
                  subtitle: details.subtitle,
                  helper: details.helper,
                  icon: details.icon,
                  color: details.color,
                  selected: mode == activeMode,
                  onTap: () {
                    setState(() {
                      _selectedMode = mode;
                      _currentStep = 2;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeader(
              number: 3,
              title: 'Тема',
              subtitle: 'Акыркы тандоо: кайсы темага фокус кылабыз.',
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: topicOptions.map((item) {
                      final selected =
                          item.category.id == selectedSnapshot.category.id;
                      final label =
                          activeGoal == _PracticeGoal.review &&
                              item.reviewDue > 0
                          ? '${item.category.title} · ${item.reviewDue}'
                          : item.category.title;
                      return AppChip(
                        label: label,
                        variant: selected
                            ? activeGoal == _PracticeGoal.review
                                  ? AppChipVariant.accent
                                  : AppChipVariant.primary
                            : AppChipVariant.defaultChip,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = item.category.id;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _TopicPreviewCard(
                    snapshot: selectedSnapshot,
                    reviewFocused: activeGoal == _PracticeGoal.review,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => context.push('/categories'),
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withValues(alpha: 0.74),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alt_route,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Толук жол картасын ачуу',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeader(
              number: 4,
              title: 'Старт',
              subtitle: 'Баары даяр. Эми түз баштай берсеңиз болот.',
            ),
            const SizedBox(height: 12),
            _FlowSummaryCard(
              plan: plan,
              onPrimary: () => context.push(plan.primaryRoute),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _nextLabelForStep(int step) {
    switch (step) {
      case 0:
        return 'Форматты тандаңыз';
      case 1:
        return 'Теманы тандаңыз';
      case 2:
        return 'Жыйынтыкка өтүү';
      default:
        return '';
    }
  }

  void _goBack(BuildContext context) {
    _handleBack(context);
  }

  void _handleBack(BuildContext context) {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
      return;
    }

    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    context.go('/home');
  }

  void _goNext() {
    if (_currentStep >= _stepTitles.length - 1) {
      return;
    }
    setState(() => _currentStep += 1);
  }

  _PracticeGoal _defaultGoal(
    ProgressProvider progress,
    _CategorySnapshot? reviewSnapshot,
  ) {
    if (progress.totalWordsMastered == 0) {
      return _PracticeGoal.start;
    }
    if (reviewSnapshot != null) {
      return _PracticeGoal.review;
    }
    return _PracticeGoal.continueLesson;
  }

  _PracticeMode _defaultModeForGoal(_PracticeGoal goal) {
    switch (goal) {
      case _PracticeGoal.review:
        return _PracticeMode.flashcards;
      case _PracticeGoal.start:
      case _PracticeGoal.continueLesson:
      case _PracticeGoal.explore:
        return _PracticeMode.flashcards;
    }
  }

  List<_PracticeMode> _modeOptionsForGoal(_PracticeGoal goal) {
    switch (goal) {
      case _PracticeGoal.review:
        return const [_PracticeMode.flashcards, _PracticeMode.quiz];
      case _PracticeGoal.start:
      case _PracticeGoal.continueLesson:
      case _PracticeGoal.explore:
        return const [
          _PracticeMode.flashcards,
          _PracticeMode.sentenceBuilder,
          _PracticeMode.quiz,
        ];
    }
  }

  String _defaultCategoryIdForGoal({
    required _PracticeGoal goal,
    required _CategorySnapshot continueSnapshot,
    required _CategorySnapshot? reviewSnapshot,
    required _CategorySnapshot fallback,
  }) {
    switch (goal) {
      case _PracticeGoal.review:
        return reviewSnapshot?.category.id ?? fallback.category.id;
      case _PracticeGoal.start:
      case _PracticeGoal.continueLesson:
        return continueSnapshot.category.id;
      case _PracticeGoal.explore:
        return fallback.category.id;
    }
  }

  List<_CategorySnapshot> _topicOptionsForGoal({
    required _PracticeGoal goal,
    required List<_CategorySnapshot> snapshots,
    required _CategorySnapshot continueSnapshot,
    required _CategorySnapshot? reviewSnapshot,
  }) {
    final unlocked = snapshots.where((item) => !item.locked).toList();
    if (unlocked.isEmpty) {
      return [_CategorySnapshot.empty()];
    }

    List<_CategorySnapshot> ordered;
    switch (goal) {
      case _PracticeGoal.review:
        ordered = unlocked.where((item) => item.reviewDue > 0).toList();
        ordered.sort((a, b) => b.reviewDue.compareTo(a.reviewDue));
        if (ordered.isEmpty && reviewSnapshot != null) {
          ordered = [reviewSnapshot];
        }
        break;
      case _PracticeGoal.start:
      case _PracticeGoal.continueLesson:
        ordered = _prioritizeSnapshot(unlocked, continueSnapshot.category.id);
        break;
      case _PracticeGoal.explore:
        ordered = unlocked;
        ordered.sort((a, b) => a.category.title.compareTo(b.category.title));
        break;
    }

    return ordered.isEmpty ? [_CategorySnapshot.empty()] : ordered;
  }

  List<_CategorySnapshot> _prioritizeSnapshot(
    List<_CategorySnapshot> items,
    String categoryId,
  ) {
    final prioritized = <_CategorySnapshot>[];
    for (final item in items) {
      if (item.category.id == categoryId) {
        prioritized.add(item);
      }
    }
    for (final item in items) {
      if (item.category.id != categoryId) {
        prioritized.add(item);
      }
    }
    return prioritized;
  }

  _CategorySnapshot _resolveSelectedSnapshot(
    List<_CategorySnapshot> options,
    String? selectedCategoryId,
  ) {
    if (options.isEmpty) return _CategorySnapshot.empty();
    for (final item in options) {
      if (item.category.id == selectedCategoryId) return item;
    }
    return options.first;
  }

  List<_GoalOption> _goalOptions({
    required ProgressProvider progress,
    required _CategorySnapshot continueSnapshot,
    required _CategorySnapshot? reviewSnapshot,
    required int totalReviewDue,
  }) {
    final options = <_GoalOption>[
      _GoalOption(
        goal: progress.totalWordsMastered == 0
            ? _PracticeGoal.start
            : _PracticeGoal.continueLesson,
        title: progress.totalWordsMastered == 0 ? 'Жеңил баштоо' : 'Улантуу',
        subtitle: progress.totalWordsMastered == 0
            ? '${continueSnapshot.category.title} менен биринчи циклди баштаңыз.'
            : '${continueSnapshot.category.title} боюнча ошол жерден улантыңыз.',
        helper: progress.totalWordsMastered == 0
            ? 'Эң аз каршылык ушул жолдо.'
            : 'Акыркы теманы улантуу эң ылдам агым.',
        icon: Icons.play_circle_fill,
        color: AppColors.primary,
      ),
    ];

    if (reviewSnapshot != null) {
      options.add(
        _GoalOption(
          goal: _PracticeGoal.review,
          title: 'Кайталоо',
          subtitle:
              '${reviewSnapshot.category.title} ичинде $totalReviewDue сөз кайра чыгууну күтүп турат.',
          helper: 'Адегенде муну жаап алуу тактык үчүн жакшы.',
          icon: Icons.refresh_rounded,
          color: AppColors.accent,
        ),
      );
    }

    options.add(
      _GoalOption(
        goal: _PracticeGoal.explore,
        title: 'Тема тандоо',
        subtitle: 'Ачылган темалардын ичинен өзүңүзгө ылайыгын тандаңыз.',
        helper: 'Максатты өзүңүз башкаргыңыз келсе ушул жол ылайыктуу.',
        icon: Icons.explore_rounded,
        color: AppColors.success,
      ),
    );

    return options;
  }

  _ModeDetails _modeDetails(_PracticeMode mode, {required bool reviewFocused}) {
    switch (mode) {
      case _PracticeMode.flashcards:
        return _ModeDetails(
          title: reviewFocused ? 'Review карточкалары' : 'Карточкалар',
          subtitle: reviewFocused
              ? 'Эстебей калган сөздөрдү кайра жабуу үчүн эң ылдам режим.'
              : 'Сөздү көрүп, эстеп, дароо бекемдеңиз.',
          helper: 'Тез темп жана эң аз күч.',
          icon: Icons.style,
          color: AppColors.primary,
        );
      case _PracticeMode.sentenceBuilder:
        return _ModeDetails(
          title: 'Сүйлөм түзүү',
          subtitle:
              'Сөздөрдү колдонууга чыгарып, структураны сезүүгө жардам берет.',
          helper: 'Тереңирээк түшүнүү үчүн.',
          icon: Icons.subject,
          color: AppColors.success,
        );
      case _PracticeMode.quiz:
        return _ModeDetails(
          title: 'Квиз',
          subtitle: reviewFocused
              ? 'Кайра чыккан сөздөрдү жооп менен текшерип көрүңүз.'
              : 'Кыска текшерүү менен ылдам баалоо алыңыз.',
          helper: 'Темп жана тактык үчүн.',
          icon: Icons.flash_on,
          color: AppColors.accent,
        );
    }
  }

  _CategorySnapshot _resolveContinueSnapshot(
    List<_CategorySnapshot> snapshots,
    String? lastCategoryId,
  ) {
    if (snapshots.isEmpty) {
      return _CategorySnapshot.empty();
    }

    for (final item in snapshots) {
      if (item.category.id == lastCategoryId) return item;
    }

    for (final item in snapshots) {
      if (!item.locked) return item;
    }

    return snapshots.first;
  }
}

class _FlowSummaryCard extends StatelessWidget {
  const _FlowSummaryCard({required this.plan, required this.onPrimary});

  final _GuidedPracticePlan plan;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plan.chips.map((chip) => _GlassTag(label: chip)).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            plan.headline,
            style: AppTextStyles.heading.copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            plan.helper,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            fullWidth: true,
            onPressed: onPrimary,
            child: Text(plan.primaryLabel),
          ),
        ],
      ),
    );
  }
}

class _WaterfallProgress extends StatelessWidget {
  const _WaterfallProgress({required this.currentStep, required this.titles});

  final int currentStep;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Кадам ${currentStep + 1}/${titles.length}',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _LinearProgress(value: (currentStep + 1) / titles.length),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: titles.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              final variant = switch (index) {
                _ when index < currentStep => AppChipVariant.success,
                _ when index == currentStep => AppChipVariant.primary,
                _ => AppChipVariant.defaultChip,
              };
              return AppChip(label: '${index + 1}. $label', variant: variant);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WaterfallActions extends StatelessWidget {
  const _WaterfallActions({
    required this.currentStep,
    required this.totalSteps,
    required this.nextLabel,
    required this.onBack,
    required this.onNext,
  });

  final int currentStep;
  final int totalSteps;
  final String nextLabel;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (currentStep >= totalSteps - 1) {
      return AppButton(
        fullWidth: true,
        variant: AppButtonVariant.outlined,
        onPressed: onBack,
        child: const Text('Тандоону өзгөртүү'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final stackButtons = constraints.maxWidth < 360 || textScale > 1.15;

        if (stackButtons) {
          return Column(
            children: [
              AppButton(
                fullWidth: true,
                onPressed: onNext,
                child: Text(nextLabel),
              ),
              const SizedBox(height: 12),
              AppButton(
                fullWidth: true,
                variant: AppButtonVariant.outlined,
                onPressed: onBack,
                child: Text(currentStep == 0 ? 'Үйгө кайтуу' : 'Артка'),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: AppButton(
                variant: AppButtonVariant.outlined,
                onPressed: onBack,
                child: Text(currentStep == 0 ? 'Үйгө кайтуу' : 'Артка'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(onPressed: onNext, child: Text(nextLabel)),
            ),
          ],
        );
      },
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final int number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.muted),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectableFlowCard extends StatelessWidget {
  const _SelectableFlowCard({
    required this.title,
    required this.subtitle,
    required this.helper,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String helper;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: selected ? color.withValues(alpha: 0.08) : null,
      borderColor: selected ? color.withValues(alpha: 0.26) : null,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, color: color, size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: AppTextStyles.body),
                const SizedBox(height: 6),
                Text(helper, style: AppTextStyles.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicPreviewCard extends StatelessWidget {
  const _TopicPreviewCard({
    required this.snapshot,
    required this.reviewFocused,
  });

  final _CategorySnapshot snapshot;
  final bool reviewFocused;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  snapshot.category.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppChip(
                label: reviewFocused && snapshot.reviewDue > 0
                    ? '${snapshot.reviewDue} кайталоо'
                    : '${snapshot.mastered}/${snapshot.totalWords} сөз',
                variant: reviewFocused && snapshot.reviewDue > 0
                    ? AppChipVariant.accent
                    : AppChipVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(snapshot.category.description, style: AppTextStyles.muted),
          const SizedBox(height: 12),
          _LinearProgress(value: snapshot.completion),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(snapshot.completion * 100).round()}% өздөштүрүлдү',
                style: AppTextStyles.caption,
              ),
              Text(
                snapshot.reviewDue > 0
                    ? '${snapshot.reviewDue} сөз күтүп турат'
                    : 'Улантууга даяр',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinearProgress extends StatelessWidget {
  const _LinearProgress({required this.value});

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

class _GlassTag extends StatelessWidget {
  const _GlassTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }
}

class _GuidedPracticePlan {
  const _GuidedPracticePlan({
    required this.headline,
    required this.description,
    required this.helper,
    required this.primaryLabel,
    required this.primaryRoute,
    required this.chips,
  });

  final String headline;
  final String description;
  final String helper;
  final String primaryLabel;
  final String primaryRoute;
  final List<String> chips;

  factory _GuidedPracticePlan.fromSelection({
    required _PracticeGoal goal,
    required _PracticeMode mode,
    required _CategorySnapshot snapshot,
    required int totalReviewDue,
    required bool hasStarted,
    required int dailyGoalMinutes,
  }) {
    final route = switch (mode) {
      _PracticeMode.flashcards
          when goal == _PracticeGoal.review && snapshot.reviewDue > 0 =>
        '/flashcards/${snapshot.category.id}?mode=review',
      _PracticeMode.flashcards => '/flashcards/${snapshot.category.id}',
      _PracticeMode.sentenceBuilder =>
        '/sentence-builder/${snapshot.category.id}',
      _PracticeMode.quiz => '/quiz/${snapshot.category.id}',
    };

    final primaryLabel = switch (mode) {
      _PracticeMode.flashcards when goal == _PracticeGoal.review =>
        'Кайталоону баштоо',
      _PracticeMode.flashcards when !hasStarted => 'Биринчи карточкаларды ачуу',
      _PracticeMode.flashcards => 'Карточкаларды ачуу',
      _PracticeMode.sentenceBuilder => 'Сүйлөм түзүү',
      _PracticeMode.quiz => 'Квизди баштоо',
    };

    final modeLabel = switch (mode) {
      _PracticeMode.flashcards => 'Карточка',
      _PracticeMode.sentenceBuilder => 'Сүйлөм',
      _PracticeMode.quiz => 'Квиз',
    };

    switch (goal) {
      case _PracticeGoal.start:
        return _GuidedPracticePlan(
          headline: 'Жеңил старт даяр',
          description:
              '${snapshot.category.title} менен тынч баштап, биринчи ритмди түзөсүз.',
          helper: 'Алгач карточка, андан кийин башка форматка өтүү жеңилирээк.',
          primaryLabel: primaryLabel,
          primaryRoute: route,
          chips: ['Старт', '$dailyGoalMinutes мүн максат', modeLabel],
        );
      case _PracticeGoal.continueLesson:
        return _GuidedPracticePlan(
          headline: 'Улантуу агымы даяр',
          description:
              '${snapshot.category.title} боюнча токтогон жериңизден кайра киресиз.',
          helper: 'Бир теманы жапмайынча башка жакка секирбөө фокусту сактайт.',
          primaryLabel: primaryLabel,
          primaryRoute: route,
          chips: [
            'Улантуу',
            '${snapshot.mastered}/${snapshot.totalWords} сөз',
            modeLabel,
          ],
        );
      case _PracticeGoal.review:
        return _GuidedPracticePlan(
          headline: 'Кайталоо агымы даяр',
          description:
              '${snapshot.category.title} ичинде ${snapshot.reviewDue} сөз кайра чыгууну күтүп турат.',
          helper: totalReviewDue > 0
              ? 'Адегенде кайталоону жаап, андан кийин жаңы циклге өтүңүз.'
              : 'Азыр review азыраак, бирок ушул тема эң ылайыктуу.',
          primaryLabel: primaryLabel,
          primaryRoute: route,
          chips: ['Review', '${snapshot.reviewDue} күтүп турат', modeLabel],
        );
      case _PracticeGoal.explore:
        return _GuidedPracticePlan(
          headline: 'Тандалган тема даяр',
          description:
              '${snapshot.category.title} боюнча өзүңүз тандаган агымды ачасыз.',
          helper:
              'Эркин тандоо жакшы, бирок бир сессияда бир гана тема кармаңыз.',
          primaryLabel: primaryLabel,
          primaryRoute: route,
          chips: ['Эркин тандоо', '${snapshot.totalWords} сөз', modeLabel],
        );
    }
  }
}

class _GoalOption {
  const _GoalOption({
    required this.goal,
    required this.title,
    required this.subtitle,
    required this.helper,
    required this.icon,
    required this.color,
  });

  final _PracticeGoal goal;
  final String title;
  final String subtitle;
  final String helper;
  final IconData icon;
  final Color color;
}

class _ModeDetails {
  const _ModeDetails({
    required this.title,
    required this.subtitle,
    required this.helper,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String helper;
  final IconData icon;
  final Color color;
}

enum _PracticeGoal { start, continueLesson, review, explore }

enum _PracticeMode { flashcards, sentenceBuilder, quiz }

class _CategorySnapshot {
  const _CategorySnapshot({
    required this.category,
    required this.mastered,
    required this.seen,
    required this.reviewDue,
    required this.completion,
    required this.locked,
  });

  _CategorySnapshot.empty()
    : category = CategoryModel(id: 'basic', title: 'Негизги', wordsCount: 0),
      mastered = 0,
      seen = 0,
      reviewDue = 0,
      completion = 0,
      locked = false;

  final CategoryModel category;
  final int mastered;
  final int seen;
  final int reviewDue;
  final double completion;
  final bool locked;

  int get totalWords => category.wordsCount;
}
