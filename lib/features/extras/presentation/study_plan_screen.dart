import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../profile/providers/progress_provider.dart';

class StudyPlanScreen extends ConsumerStatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  ConsumerState<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends ConsumerState<StudyPlanScreen> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressProvider).load();
      ref.read(onboardingProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final onboarding = ref.watch(onboardingProvider);
    final stages = _buildStages(onboarding.dailyGoalMinutes);
    final currentIndex = _resolveCurrentIndex(
      progress.totalWordsMastered,
      stages,
    );
    final selectedIndex = _resolveSelectedIndex(currentIndex, stages.length);
    final selectedStage = stages[selectedIndex];
    final overallTarget = stages[stages.length - 2].wordsTarget;
    final overallProgress = overallTarget == 0
        ? 0.0
        : (progress.totalWordsMastered / overallTarget).clamp(0, 1).toDouble();

    return AppShell(
      title: 'Жол картасы',
      subtitle: 'Окуу баскычтары жана кийинки кадам',
      activeTab: AppTab.learn,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/profile',
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          AppCard(
            gradient: true,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GlassTag(label: '${progress.streakDays} күн серия'),
                    _GlassTag(label: '${progress.totalWordsMastered} сөз'),
                    _GlassTag(label: '${onboarding.dailyGoalMinutes} мүн goal'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Жолду ачып, ритмди сактаңыз',
                  style: AppTextStyles.heading.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Бул экран окуу жолун жөнөкөй кылып көрсөтөт: азыр кайсы фазадасыз, эмнени жабышыңыз керек жана кийинки чекит кайда.',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                _HeroProgressBar(value: overallProgress),
                const SizedBox(height: 8),
                Text(
                  '${(overallProgress * 100).round()}% негизги жол ачылды',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: () => context.push('/categories'),
                        child: const Text('Категория roadmap'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.outlined,
                        onPressed: () => context.push('/practice'),
                        child: const Text('Практикага өтүү'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Азыркы этап',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SelectedStageCard(
            stage: selectedStage,
            state: _stageState(selectedIndex, currentIndex),
            wordsMastered: progress.totalWordsMastered,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Этаптар', style: AppTextStyles.title),
              const Spacer(),
              AppChip(
                label: '${currentIndex + 1}/${stages.length}',
                variant: AppChipVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final state = _stageState(index, currentIndex);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StageCard(
                stage: stage,
                state: state,
                selected: index == selectedIndex,
                onTap: () => setState(() => _selectedIndex = index),
              ),
            );
          }),
        ],
      ),
    );
  }

  int _resolveSelectedIndex(int currentIndex, int length) {
    final requested = _selectedIndex ?? currentIndex;
    if (requested < 0) return 0;
    if (requested >= length) return length - 1;
    return requested;
  }

  List<_RoadmapStage> _buildStages(int dailyGoalMinutes) {
    return [
      _RoadmapStage(
        title: 'Base Camp',
        headline: 'Ритмди түзүү',
        description:
            'Биринчи максат күнүмдүк окууну иштетүү. Бул жерде негизги карточка цикли жана биринчи progress signal пайда болот.',
        focus: 'Карточка + кыска квиз',
        milestone: 'Биринчи туруктуу серия',
        wordsTarget: 5,
        tasks: [
          'Күнүнө жок дегенде $dailyGoalMinutes мүнөт кирүү',
          'Алгачкы сөздөрдү ачуу',
          'Биринчи streak баштоо',
        ],
      ),
      _RoadmapStage(
        title: 'Daily Rhythm',
        headline: 'Темпти кармоо',
        description:
            'Эми максат жөн гана сөз көрүү эмес. Continue, review жана quiz бир цикл болуп иштей баштайт.',
        focus: 'Continue + review due',
        milestone: 'Туруктуу окуу цикли',
        wordsTarget: 15,
        tasks: [
          'Review due сөздөрдү бошотуу',
          'Күндүк максатты үзбөө',
          'Бир теманы бир нече режим менен бекемдөө',
        ],
      ),
      _RoadmapStage(
        title: 'Conversation Loops',
        headline: 'Сүйлөм менен бекемдөө',
        description:
            'Бул этапта сөздөр сүйлөмгө өтөт. Sentence builder жана quiz чыныгы колдонууга жакындатат.',
        focus: 'Sentence builder + mistakes review',
        milestone: 'Активдүү колдонуу',
        wordsTarget: 30,
        tasks: [
          'Сүйлөм түзүүнү көбөйтүү',
          'Ката кеткен сөздөрдү кайра айлантуу',
          'Контекст менен эстөөнү күчөтүү',
        ],
      ),
      _RoadmapStage(
        title: 'Mastery Stretch',
        headline: 'Тактыкты жогорулатуу',
        description:
            'Бул жерде сан эмес, сапат маанилүү. Тактык, серия жана review pressure негизги сигналга айланат.',
        focus: 'Accuracy + streak',
        milestone: 'Таза аткаруу',
        wordsTarget: 50,
        tasks: [
          '80%+ тактыкты кармоо',
          'Review кезегин өз убагында жабуу',
          'Алсыз темаларды кайра иштетүү',
        ],
      ),
      _RoadmapStage(
        title: 'Open Steppe',
        headline: 'Эркин аралаш practice',
        description:
            'Негизги жол ачылгандан кийин практика аралаш режимге өтөт. Эми roadmap эмес, өзүңүздүн ритмиңиз башкы ролдо.',
        focus: 'Mixed practice',
        milestone: 'Туруктуу fluency loop',
        wordsTarget: 999,
        tasks: [
          'Категорияларды аралаш квиз менен текшерүү',
          'Алсыз темаларга өзүнчө кайтуу',
          'Темпти сактоо жана сапатты бекемдөө',
        ],
      ),
    ];
  }

  int _resolveCurrentIndex(int wordsMastered, List<_RoadmapStage> stages) {
    for (var i = 0; i < stages.length; i++) {
      if (wordsMastered < stages[i].wordsTarget) {
        return i;
      }
    }
    return stages.length - 1;
  }

  _RoadmapStageState _stageState(int index, int currentIndex) {
    if (index < currentIndex) return _RoadmapStageState.completed;
    if (index == currentIndex) return _RoadmapStageState.current;
    return _RoadmapStageState.upcoming;
  }
}

class _SelectedStageCard extends StatelessWidget {
  const _SelectedStageCard({
    required this.stage,
    required this.state,
    required this.wordsMastered,
  });

  final _RoadmapStage stage;
  final _RoadmapStageState state;
  final int wordsMastered;

  @override
  Widget build(BuildContext context) {
    final remaining = (stage.wordsTarget - wordsMastered).clamp(0, 999);
    return AppCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: _tint(state),
      borderColor: _border(state),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(
                label: _label(state),
                variant: _variant(state),
              ),
              AppChip(
                label: stage.focus,
                variant: AppChipVariant.defaultChip,
              ),
              AppChip(
                label: stage.wordsTarget >= 999
                    ? '50+ сөз'
                    : '${stage.wordsTarget} сөз чекити',
                variant: AppChipVariant.defaultChip,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(stage.title, style: AppTextStyles.title.copyWith(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            stage.headline,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(stage.description, style: AppTextStyles.body),
          const SizedBox(height: 14),
          Text(
            stage.wordsTarget >= 999
                ? 'Негизги roadmap ачылды.'
                : 'Дагы $remaining сөз бекемделсе, бул чекит жабылат.',
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: 14),
          ...stage.tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(task, style: AppTextStyles.body)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _tint(_RoadmapStageState state) {
    switch (state) {
      case _RoadmapStageState.completed:
        return AppColors.success.withValues(alpha: 0.06);
      case _RoadmapStageState.current:
        return AppColors.primary.withValues(alpha: 0.06);
      case _RoadmapStageState.upcoming:
        return AppColors.surface;
    }
  }

  Color _border(_RoadmapStageState state) {
    switch (state) {
      case _RoadmapStageState.completed:
        return AppColors.success.withValues(alpha: 0.2);
      case _RoadmapStageState.current:
        return AppColors.primary.withValues(alpha: 0.24);
      case _RoadmapStageState.upcoming:
        return AppColors.border;
    }
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.stage,
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final _RoadmapStage stage;
  final _RoadmapStageState state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(state);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      backgroundColor: selected
          ? accent.withValues(alpha: 0.06)
          : AppColors.surface,
      borderColor: selected
          ? accent.withValues(alpha: 0.24)
          : AppColors.border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stage.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppChip(
                      label: _label(state),
                      variant: _variant(state),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(stage.headline, style: AppTextStyles.title),
                const SizedBox(height: 6),
                Text(stage.description, style: AppTextStyles.muted),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppChip(
                      label: stage.focus,
                      variant: AppChipVariant.defaultChip,
                    ),
                    AppChip(
                      label: stage.milestone,
                      variant: AppChipVariant.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _accent(_RoadmapStageState state) {
    switch (state) {
      case _RoadmapStageState.completed:
        return AppColors.success;
      case _RoadmapStageState.current:
        return AppColors.primary;
      case _RoadmapStageState.upcoming:
        return AppColors.muted;
    }
  }
}

class _HeroProgressBar extends StatelessWidget {
  const _HeroProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        backgroundColor: Colors.white.withValues(alpha: 0.18),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD684)),
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

class _RoadmapStage {
  const _RoadmapStage({
    required this.title,
    required this.headline,
    required this.description,
    required this.focus,
    required this.milestone,
    required this.wordsTarget,
    required this.tasks,
  });

  final String title;
  final String headline;
  final String description;
  final String focus;
  final String milestone;
  final int wordsTarget;
  final List<String> tasks;
}

enum _RoadmapStageState { completed, current, upcoming }

String _label(_RoadmapStageState state) {
  switch (state) {
    case _RoadmapStageState.completed:
      return 'Аяктады';
    case _RoadmapStageState.current:
      return 'Азыр ушул жерде';
    case _RoadmapStageState.upcoming:
      return 'Кийинки';
  }
}

AppChipVariant _variant(_RoadmapStageState state) {
  switch (state) {
    case _RoadmapStageState.completed:
      return AppChipVariant.success;
    case _RoadmapStageState.current:
      return AppChipVariant.primary;
    case _RoadmapStageState.upcoming:
      return AppChipVariant.defaultChip;
  }
}
