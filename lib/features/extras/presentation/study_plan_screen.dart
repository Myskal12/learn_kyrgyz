import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../profile/providers/progress_provider.dart';

class StudyPlanScreen extends ConsumerStatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  ConsumerState<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends ConsumerState<StudyPlanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
    final selectedIndex = _selectedIndex ?? currentIndex;
    final selectedStage = stages[selectedIndex];
    final overallProgress = ((progress.totalWordsMastered / 50).clamp(
      0,
      1,
    )).toDouble();

    return AppShell(
      title: 'Roadmap',
      subtitle: 'Интерактивдүү окуу картасы',
      activeTab: AppTab.learn,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/profile',
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _RoadmapHero(
            controller: _pulseController,
            overallProgress: overallProgress,
            streakDays: progress.streakDays,
            totalWordsMastered: progress.totalWordsMastered,
            dailyGoalMinutes: onboarding.dailyGoalMinutes,
          ),
          const SizedBox(height: 18),
          _SelectedStagePanel(
            stage: selectedStage,
            index: selectedIndex,
            state: _stageState(selectedIndex, currentIndex),
            wordsMastered: progress.totalWordsMastered,
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Жол картасы', style: AppTextStyles.title),
              const Spacer(),
              AppChip(
                label: 'Азыркы баскыч: ${currentIndex + 1}/${stages.length}',
                variant: AppChipVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final state = _stageState(index, currentIndex);
            final isSelected = index == selectedIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child:
                  _RoadmapStageCard(
                        stage: stage,
                        index: index,
                        state: state,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedIndex = index),
                      )
                      .animate(delay: Duration(milliseconds: 80 * index))
                      .fadeIn(duration: 350.ms)
                      .slideX(begin: index.isEven ? -0.05 : 0.05, end: 0),
            );
          }),
        ],
      ),
    );
  }

  List<_RoadmapStage> _buildStages(int dailyGoalMinutes) {
    return [
      _RoadmapStage(
        title: 'Base Camp',
        kicker: '0-5 сөз',
        duration: '1 жума',
        headline: 'Ритмди түзүү',
        description:
            'Алгачкы максат окууну күнүмдүк адатка айлантуу. Бул жерде каркас курулат.',
        focus: 'Карточка + кыска квиз',
        milestone: 'Биринчи туруктуу серия',
        wordsTarget: 5,
        gradient: [const Color(0xFF805B3D), const Color(0xFFB97C45)],
        tasks: [
          'Күнүнө кеминде $dailyGoalMinutes мүнөт практика',
          'Негизги сөздөрдү ачуу',
          'Биринчи streak баштоо',
        ],
      ),
      _RoadmapStage(
        title: 'Daily Rhythm',
        kicker: '5-15 сөз',
        duration: '2 жума',
        headline: 'Темпти бекемдөө',
        description:
            'Эми максат бир режим менен эле чектелбестен, flashcards, quiz жана sentence builder ортосунда жүрүү.',
        focus: 'Continue + review due',
        milestone: 'Туруктуу окуу цикли',
        wordsTarget: 15,
        gradient: [AppColors.primary, const Color(0xFFF7C15C)],
        tasks: [
          'Ката кеткен сөздөрдү жабуу',
          'Күндүк максатты үзбөө',
          'Бир теманы үч режим менен бекемдөө',
        ],
      ),
      _RoadmapStage(
        title: 'Conversation Loops',
        kicker: '15-30 сөз',
        duration: '3 жума',
        headline: 'Сүйлөм менен ойноо',
        description:
            'Сөздөрдү таануу жетишсиз. Бул этапта аларды сүйлөмдөргө чогултуу башкы роль ойнойт.',
        focus: 'Sentence builder + mistakes review',
        milestone: 'Активдүү колдонуу',
        wordsTarget: 30,
        gradient: [const Color(0xFF155E75), const Color(0xFF38BDF8)],
        tasks: [
          'Сүйлөм түзүүдө тактыкты көтөрүү',
          'Квизден кийин түз эле review кылуу',
          'Тема боюнча pattern таануу',
        ],
      ),
      _RoadmapStage(
        title: 'Mastery Stretch',
        kicker: '30-50 сөз',
        duration: '4 жума',
        headline: 'Тактыкты жогорулатуу',
        description:
            'Бул жерде прогресс сөз санынан сапатка өтөт: тактык, серия жана туруктуу recall.',
        focus: 'Accuracy + streak',
        milestone: 'Таза аткаруу',
        wordsTarget: 50,
        gradient: [AppColors.accent, const Color(0xFFE57373)],
        tasks: [
          '80%+ тактык кармоо',
          'Жумалык чакырыкты жабуу',
          'Алсыз темаларды кайра айлантуу',
        ],
      ),
      _RoadmapStage(
        title: 'Open Steppe',
        kicker: '50+ сөз',
        duration: 'үзгүлтүксүз',
        headline: 'Эркин айкалыштыруу',
        description:
            'Акыркы фаза статикалык чек эмес. Бул жерде өзүңүздүн ритмиңизди сактап, категорияларды аралаш колдоносуз.',
        focus: 'Mixed practice',
        milestone: 'Туруктуу fluency loop',
        wordsTarget: 999,
        gradient: [const Color(0xFF3F7D4E), const Color(0xFF7CCB6B)],
        tasks: [
          'Категорияларды аралаш квиз менен текшерүү',
          'Кыйын темаларды өзүнчө roadmap кылуу',
          'Өз pace менен улантуу',
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

class _RoadmapHero extends StatelessWidget {
  const _RoadmapHero({
    required this.controller,
    required this.overallProgress,
    required this.streakDays,
    required this.totalWordsMastered,
    required this.dailyGoalMinutes,
  });

  final AnimationController controller;
  final double overallProgress;
  final int streakDays;
  final int totalWordsMastered;
  final int dailyGoalMinutes;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pulse = Curves.easeInOut.transform(controller.value);
        final imageOffset = math.sin(controller.value * math.pi * 2) * 6;
        return Container(
          height: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              colors: [Color(0xFF120C0B), Color(0xFF6E3F1D), Color(0xFFCF9C4A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: -36,
                top: 42,
                child: _GlowRing(size: 170, opacity: 0.12 + pulse * 0.08),
              ),
              Positioned(
                right: -28,
                bottom: 22,
                child: _GlowRing(size: 130, opacity: 0.1 + pulse * 0.06),
              ),
              Positioned(
                top: 28,
                left: 22,
                right: 22,
                child: Row(
                  children: [
                    _GlassMetric(label: 'Серия', value: '$streakDays күн'),
                    const SizedBox(width: 10),
                    _GlassMetric(label: 'Сөздөр', value: '$totalWordsMastered'),
                    const Spacer(),
                    _GlassMetric(label: 'Goal', value: '$dailyGoalMinutes мүн'),
                  ],
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yurt Roadmap',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Окуу жолуңузду көзгө көрүнгөн картага айлантыңыз',
                      style: AppTextStyles.heading.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        minHeight: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD684),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(overallProgress * 100).round()}% жол ачылды',
                      style: AppTextStyles.body.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0.45, -0.05),
                    child: Transform.translate(
                      offset: Offset(0, imageOffset),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 190 + pulse * 18,
                            height: 190 + pulse * 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          Container(
                            width: 154,
                            height: 154,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1.5,
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/yurt.png',
                              width: 148,
                              height: 148,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectedStagePanel extends StatelessWidget {
  const _SelectedStagePanel({
    required this.stage,
    required this.index,
    required this.state,
    required this.wordsMastered,
  });

  final _RoadmapStage stage;
  final int index;
  final _RoadmapStageState state;
  final int wordsMastered;

  @override
  Widget build(BuildContext context) {
    final remaining = math.max(stage.wordsTarget - wordsMastered, 0);
    final stateLabel = switch (state) {
      _RoadmapStageState.completed => 'Аяктады',
      _RoadmapStageState.current => 'Азыр ушул жерде',
      _RoadmapStageState.upcoming =>
        remaining > 0 ? 'Дагы $remaining сөз керек' : 'Кийинки чекит',
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Container(
        key: ValueKey(stage.title),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: stage.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.title.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stage.title, style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(stateLabel, style: AppTextStyles.muted),
                    ],
                  ),
                ),
                AppChip(
                  label: stage.kicker,
                  variant: state == _RoadmapStageState.current
                      ? AppChipVariant.accent
                      : AppChipVariant.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stage.headline,
              style: AppTextStyles.heading.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(stage.description, style: AppTextStyles.body),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChip(
                  label: 'Фокус: ${stage.focus}',
                  variant: AppChipVariant.defaultChip,
                ),
                AppChip(
                  label: 'Milestone: ${stage.milestone}',
                  variant: AppChipVariant.success,
                ),
                AppChip(
                  label: 'Duration: ${stage.duration}',
                  variant: AppChipVariant.defaultChip,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapStageCard extends StatelessWidget {
  const _RoadmapStageCard({
    required this.stage,
    required this.index,
    required this.state,
    required this.isSelected,
    required this.onTap,
  });

  final _RoadmapStage stage;
  final int index;
  final _RoadmapStageState state;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (state) {
      _RoadmapStageState.completed => AppColors.success,
      _RoadmapStageState.current => AppColors.accent,
      _RoadmapStageState.upcoming => AppColors.muted,
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: isSelected
              ? AppColors.surface
              : AppColors.surface.withValues(alpha: 0.84),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.44)
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accent.withValues(alpha: 0.16)
                  : AppColors.cardShadow,
              blurRadius: isSelected ? 26 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      width: isSelected ? 18 : 14,
                      height: isSelected ? 18 : 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.32),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                    if (index < 4)
                      Container(
                        width: 2,
                        height: 80,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              accent.withValues(alpha: 0.6),
                              accent.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
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
                            Text(stage.duration, style: AppTextStyles.caption),
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
                              label: stage.kicker,
                              variant: AppChipVariant.defaultChip,
                            ),
                            AppChip(
                              label: stage.focus,
                              variant: state == _RoadmapStageState.current
                                  ? AppChipVariant.accent
                                  : AppChipVariant.primary,
                            ),
                          ],
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 14),
                          ...stage.tasks.asMap().entries.map((taskEntry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(top: 1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: stage.gradient.first.withValues(
                                        alpha: 0.14,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${taskEntry.key + 1}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: stage.gradient.first,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      taskEntry.value,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowRing extends StatelessWidget {
  const _GlowRing({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _GlassMetric extends StatelessWidget {
  const _GlassMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapStage {
  const _RoadmapStage({
    required this.title,
    required this.kicker,
    required this.duration,
    required this.headline,
    required this.description,
    required this.focus,
    required this.milestone,
    required this.wordsTarget,
    required this.gradient,
    required this.tasks,
  });

  final String title;
  final String kicker;
  final String duration;
  final String headline;
  final String description;
  final String focus;
  final String milestone;
  final int wordsTarget;
  final List<Color> gradient;
  final List<String> tasks;
}

enum _RoadmapStageState { completed, current, upcoming }
