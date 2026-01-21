import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_shell.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late Future<List<UserProfileModel>> _future;

  @override
  void initState() {
    super.initState();
    final service = ref.read(firebaseServiceProvider);
    _future = service.fetchLeaderboard(limit: 12);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Рейтинг',
      subtitle: 'Жума жана сезон',
      activeTab: AppTab.progress,
      child: FutureBuilder<List<UserProfileModel>>(
        future: _future,
        builder: (context, snapshot) {
          final fallback = _fallbackEntries();
          final entries = snapshot.hasData && snapshot.data!.isNotEmpty
              ? _mapEntries(snapshot.data!)
              : fallback;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Text('Рейтинг', style: AppTextStyles.heading.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                'Башкалар менен салыштырып, жетишкендиктерди көрөсүз',
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              AppCard(
                gradient: true,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Сиздин ордуңуз',
                              style: AppTextStyles.muted.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '3-орун',
                              style: AppTextStyles.heading.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        _GlassChip(label: '1685 упай'),
                        SizedBox(width: 8),
                        _GlassChip(label: '12 күн катар'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Топ катышуучулар',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const AppChip(
                    label: 'Бул жума',
                    variant: AppChipVariant.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isTop = index < 3;
                final highlight = item.highlight;
                final highlightColors = _highlightColors(highlight);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: isTop
                                ? LinearGradient(colors: highlightColors)
                                : null,
                            color:
                                isTop ? null : AppColors.mutedSurface,
                          ),
                          alignment: Alignment.center,
                          child: isTop
                              ? Icon(
                                  index == 0
                                      ? Icons.workspace_premium
                                      : index == 1
                                          ? Icons.emoji_events
                                          : Icons.star,
                                  color: AppColors.textDark,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muted,
                                  ),
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
                                      item.name,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (item.isYou)
                                    const AppChip(
                                      label: 'Сиз',
                                      variant: AppChipVariant.primary,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.points} упай · ${item.streak} күн катар',
                                style: AppTextStyles.muted,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(Icons.local_fire_department,
                                size: 16, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              item.streak.toString(),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CircleIcon(
                          icon: Icons.emoji_events,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Апталык чакырык',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '7 күн катар окуп, атайын төш белгини алыңыз',
                                style: AppTextStyles.muted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ProgressBar(value: 0.7),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('5/7 күн', style: AppTextStyles.muted),
                        Text(
                          'Даяр',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_LeaderboardEntry> _mapEntries(List<UserProfileModel> users) {
    return users.take(6).map((user) {
      final points = user.totalMastered * 6 + user.totalSessions * 2;
      return _LeaderboardEntry(
        name: user.nickname,
        points: points,
        streak: user.totalSessions,
      );
    }).toList();
  }

  List<_LeaderboardEntry> _fallbackEntries() {
    return [
      _LeaderboardEntry(
        name: 'Алина Токтобаева',
        points: 1860,
        streak: 18,
        highlight: _Highlight.gold,
      ),
      _LeaderboardEntry(
        name: 'Бекзат уулу Айбек',
        points: 1720,
        streak: 15,
        highlight: _Highlight.silver,
      ),
      _LeaderboardEntry(
        name: 'Айгүл Асанова',
        points: 1685,
        streak: 12,
        highlight: _Highlight.bronze,
        isYou: true,
      ),
      _LeaderboardEntry(
        name: 'Элина Назарова',
        points: 1605,
        streak: 11,
      ),
      _LeaderboardEntry(
        name: 'Темирлан Мусаев',
        points: 1540,
        streak: 10,
      ),
      _LeaderboardEntry(
        name: 'Асия Рысбекова',
        points: 1498,
        streak: 9,
      ),
    ];
  }

  List<Color> _highlightColors(_Highlight highlight) {
    switch (highlight) {
      case _Highlight.gold:
        return [AppColors.primary, const Color(0xFFF7C15C)];
      case _Highlight.silver:
        return [
          AppColors.muted.withValues(alpha: 0.3),
          AppColors.muted.withValues(alpha: 0.1),
        ];
      case _Highlight.bronze:
        return [const Color(0xFFC47A3A), const Color(0xFFE3A870)];
      case _Highlight.none:
        return [AppColors.mutedSurface, AppColors.mutedSurface];
    }
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: color, size: 20),
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
          widthFactor: value,
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

class _LeaderboardEntry {
  _LeaderboardEntry({
    required this.name,
    required this.points,
    required this.streak,
    this.highlight = _Highlight.none,
    this.isYou = false,
  });

  final String name;
  final int points;
  final int streak;
  final _Highlight highlight;
  final bool isYou;
}

enum _Highlight { none, gold, silver, bronze }
