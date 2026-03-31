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
            stages: stages,
            currentIndex: currentIndex,
            selectedIndex: selectedIndex,
            onStageSelected: (index) => setState(() => _selectedIndex = index),
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
                        showConnector: index != stages.length - 1,
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
    required this.stages,
    required this.currentIndex,
    required this.selectedIndex,
    required this.onStageSelected,
  });

  final AnimationController controller;
  final double overallProgress;
  final int streakDays;
  final int totalWordsMastered;
  final int dailyGoalMinutes;
  final List<_RoadmapStage> stages;
  final int currentIndex;
  final int selectedIndex;
  final ValueChanged<int> onStageSelected;

  @override
  Widget build(BuildContext context) {
    final selectedStage = stages[selectedIndex];
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pulse = Curves.easeInOut.transform(controller.value);
        final imageOffset = math.sin(controller.value * math.pi * 2) * 10;
        return Container(
          height: 468,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              colors: [Color(0xFF150F0C), Color(0xFF5A341A), Color(0xFFD3A056)],
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
              Positioned.fill(
                child: CustomPaint(painter: _ContourPainter(progress: pulse)),
              ),
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
                top: 24,
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
                top: 96,
                right: 164,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yurt roadmap',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Юрта аркылуу өсүү жолун көрүнө турган окуу трегине айлантыңыз',
                      style: AppTextStyles.heading.copyWith(
                        color: Colors.white,
                        fontSize: 31,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Container(
                        key: ValueKey(selectedStage.title),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedStage.title,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedStage.headline,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withValues(alpha: 0.84),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _HeroTag(label: selectedStage.kicker),
                                _HeroTag(label: selectedStage.focus),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 6),
                    Text(
                      'Картадагы чекиттерди таптап, ар бир фазанын тапшырмасын караңыз.',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0.72, -0.06),
                    child: Transform.translate(
                      offset: Offset(0, imageOffset),
                      child: Transform.rotate(
                        angle: math.sin(controller.value * math.pi * 2) * 0.018,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 260 + pulse * 22,
                              height: 260 + pulse * 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(
                                      0xFFFFE5AA,
                                    ).withValues(alpha: 0.34),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 18,
                              child: Container(
                                width: 210,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.34),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/yurt.png',
                              width: 248,
                              height: 248,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) {
                                return const _YurtFallback();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: _HeroRoadTrack(
                  stages: stages,
                  currentIndex: currentIndex,
                  selectedIndex: selectedIndex,
                  onStageSelected: onStageSelected,
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
    required this.showConnector,
    required this.onTap,
  });

  final _RoadmapStage stage;
  final int index;
  final _RoadmapStageState state;
  final bool isSelected;
  final bool showConnector;
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
                    if (showConnector)
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

class _HeroRoadTrack extends StatelessWidget {
  const _HeroRoadTrack({
    required this.stages,
    required this.currentIndex,
    required this.selectedIndex,
    required this.onStageSelected,
  });

  final List<_RoadmapStage> stages;
  final int currentIndex;
  final int selectedIndex;
  final ValueChanged<int> onStageSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: SizedBox(
        height: 92,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RoadTrackPainter(
                  currentIndex: currentIndex,
                  selectedIndex: selectedIndex,
                  stageCount: stages.length,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stages.asMap().entries.map((entry) {
                final index = entry.key;
                final stage = entry.value;
                final isCurrent = index == currentIndex;
                final isSelected = index == selectedIndex;
                final isCompleted = index < currentIndex;
                final color = isCompleted
                    ? AppColors.success
                    : isCurrent
                    ? const Color(0xFFFFD684)
                    : Colors.white70;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onStageSelected(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          width: isSelected
                              ? 22
                              : isCurrent
                              ? 18
                              : 14,
                          height: isSelected
                              ? 22
                              : isCurrent
                              ? 18
                              : 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.44),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(
                                  alpha: isSelected ? 0.44 : 0.22,
                                ),
                                blurRadius: isSelected ? 20 : 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${index + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stage.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }
}

class _YurtFallback extends StatelessWidget {
  const _YurtFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home_work_rounded, size: 56, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            'Yurt asset',
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

class _ContourPainter extends CustomPainter {
  const _ContourPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final inset = 24.0 + (i * 28);
      final rect = Rect.fromLTWH(
        inset,
        40 + i * 12,
        size.width - inset * 2,
        size.height - 180 - i * 16,
      );
      paint.color = Colors.white.withValues(
        alpha: 0.035 + (i == 1 ? progress * 0.02 : 0),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(56 - i * 6)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ContourPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _RoadTrackPainter extends CustomPainter {
  const _RoadTrackPainter({
    required this.currentIndex,
    required this.selectedIndex,
    required this.stageCount,
  });

  final int currentIndex;
  final int selectedIndex;
  final int stageCount;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[];
    const yStops = [0.72, 0.42, 0.63, 0.34, 0.58];
    for (var i = 0; i < stageCount; i++) {
      final dx = stageCount == 1
          ? size.width / 2
          : size.width * (i / (stageCount - 1));
      final dy = size.height * yStops[i.clamp(0, yStops.length - 1)];
      points.add(Offset(dx, dy));
    }

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.16);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE3A1), Color(0xFFFFB862)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final basePath = _buildSmoothPath(points);
    canvas.drawPath(basePath, basePaint);

    final activePoints = points
        .take(math.min(currentIndex + 1, points.length))
        .toList();
    if (activePoints.length >= 2) {
      canvas.drawPath(_buildSmoothPath(activePoints), activePaint);
    }

    if (selectedIndex < points.length) {
      final selected = points[selectedIndex];
      final glow = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selected, 18, glow);
    }
  }

  Path _buildSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) {
      return path;
    }
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final control = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(previous.dx, previous.dy, control.dx, control.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant _RoadTrackPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.stageCount != stageCount;
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
