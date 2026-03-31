import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/sticky_bottom_action_bar.dart';

class LessonOverviewScreen extends StatelessWidget {
  const LessonOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Сабак тууралуу',
      subtitle: 'Баштоодон мурун кыскача',
      activeTab: AppTab.learn,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/categories',
      showBottomNav: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFF3DB),
                  Color(0xFFFDF6E8),
                  Color(0xFFF9E8E0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -20,
                              child: _GlowCircle(
                                colors: [
                                  AppColors.primary,
                                  const Color(0xFFF7C15C),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: -20,
                              left: -20,
                              child: _GlowCircle(
                                colors: [
                                  AppColors.accent,
                                  const Color(0xFFB71C1C),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.accent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 12,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Саякат үчүн кеңири сүйлөмдөр',
                                  style: AppTextStyles.heading.copyWith(
                                    fontSize: 26,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Багыт сурап-билүү, тамак заказ кылуу жана жаңы достор менен сүйлөшүү үчүн негизги сөз айкаштарын үйрөнөбүз.',
                                  style: AppTextStyles.muted,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Практика кылынуучу көндүмдөр',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _SkillChip(
                            label: 'Сүйлөө',
                            background: Color.fromRGBO(242, 177, 61, 0.15),
                            textColor: Color(0xFF1F1F1F),
                          ),
                          _SkillChip(
                            label: 'Угуу',
                            background: Color.fromRGBO(25, 118, 210, 0.1),
                            textColor: Color(0xFF1976D2),
                          ),
                          _SkillChip(
                            label: 'Сөздүк',
                            background: Color.fromRGBO(198, 40, 40, 0.1),
                            textColor: Color(0xFFC62828),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppCard(
                              radius: AppCardRadius.md,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Кыйынчылык',
                                        style: AppTextStyles.muted,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Орточо',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppCard(
                              radius: AppCardRadius.md,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: AppColors.accent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Убакыт',
                                        style: AppTextStyles.muted,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '15 мүнөт',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        radius: AppCardRadius.md,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Эмне үйрөнөсүз',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _OutcomeRow(
                              text:
                                  'Ар кандай кырдаалда саламдашуу жана таанышуу',
                            ),
                            const SizedBox(height: 8),
                            _OutcomeRow(text: 'Багыт сурап, жоопту түшүнүү'),
                            const SizedBox(height: 8),
                            _OutcomeRow(
                              text: 'Ресторанда ишенимдүү заказ берүү',
                            ),
                            const SizedBox(height: 8),
                            _OutcomeRow(
                              text: 'Жолдо жардам сураган учурда сүйлөшүү',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Жакшы темп менен келе жатасыз!',
                        style: AppTextStyles.muted,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                StickyBottomActionBar(
                  child: AppCard(
                    radius: AppCardRadius.lg,
                    gradient: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    onTap: () => context.push('/practice'),
                    child: Center(
                      child: Text(
                        'Сабакты баштоо',
                        key: const Key('lesson-overview-primary-cta'),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTextStyles.body.copyWith(fontSize: 14)),
        ),
      ],
    );
  }
}
