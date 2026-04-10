import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_pattern_background.dart';
import '../../../shared/widgets/sticky_bottom_action_bar.dart';
import '../../auth/providers/auth_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final auth = ref.watch(authProvider);
    final selectedGoal = onboarding.dailyGoalMinutes;
    final googleSupported = auth.isGoogleSignInSupported;

    Future<void> continueAsGuest() async {
      await ref.read(localStorageServiceProvider).setString(
        Constants.postLogoutRedirectKey,
        'false',
      );
      await ref.read(onboardingProvider).completeOnboarding();
      if (!context.mounted) return;
      context.go('/home');
    }

    Future<void> continueWithGoogle() async {
      final ok = await ref.read(authProvider).loginWithGoogle();
      if (!context.mounted) return;
      if (!ok) {
        final error = ref.read(authProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
        return;
      }
      await ref.read(localStorageServiceProvider).setString(
        Constants.postLogoutRedirectKey,
        'false',
      );
      await ref.read(onboardingProvider).completeOnboarding();
      if (!context.mounted) return;
      context.go('/auth-complete');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AppPatternBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        children: [
                          AppCard(
                            gradient: true,
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.24,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Биринчи күндөн баштаңыз',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Кыргызчаны жеңил жана сулуу ритм менен үйрөнүңүз',
                                  style: AppTextStyles.heading.copyWith(
                                    color: Colors.white,
                                    fontSize: 30,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Максатты тандап, дароо баштаңыз.',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _ValueCard(
                            icon: Icons.bolt,
                            title: 'Тез башталат',
                            subtitle: 'Биринчи сабакка түз өтөсүз.',
                          ),
                          const SizedBox(height: 12),
                          const _ValueCard(
                            icon: Icons.menu_book,
                            title: 'Кыска практика',
                            subtitle: 'Карточка, квиз, сүйлөм бир жерде.',
                          ),
                          const SizedBox(height: 12),
                          const _ValueCard(
                            icon: Icons.cloud_done,
                            title: 'Конок режими',
                            subtitle: 'Азыр баштап, кийин кире аласыз.',
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Күндүк максат',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Күнүнө канча убакыт бөлгүңүз келет?',
                            style: AppTextStyles.muted,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: onboarding.dailyGoalOptions
                                .map((minutes) => _GoalChoice(minutes: minutes))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Кааласаңыз кийин өзгөртөсүз.',
                            style: AppTextStyles.muted,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            padding: const EdgeInsets.all(18),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
                            borderColor: AppColors.primary.withValues(
                              alpha: 0.18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Кирүү жолдору',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Кааласаңыз Google менен кириңиз.',
                                  style: AppTextStyles.muted,
                                ),
                                const SizedBox(height: 12),
                                AppButton(
                                  fullWidth: true,
                                  size: AppButtonSize.md,
                                  variant: AppButtonVariant.accent,
                                  onPressed: auth.isLoading || !googleSupported
                                      ? null
                                      : continueWithGoogle,
                                  child: const Text('Google менен улантуу'),
                                ),
                                if (!googleSupported) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    auth.googleSignInUnavailableMessage,
                                    style: AppTextStyles.muted.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    StickyBottomActionBar(
                      maxWidth: 420,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (auth.error != null && !auth.isLoading)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                auth.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          AppButton(
                            key: const Key('welcome-primary-cta'),
                            fullWidth: true,
                            size: AppButtonSize.lg,
                            onPressed: auth.isLoading ? null : continueAsGuest,
                            child: Text(
                              'Конок катары баштоо · $selectedGoal мүн',
                            ),
                          ),
                          const SizedBox(height: 10),
                          AdaptivePanelGrid(
                            maxColumns: 2,
                            minItemWidth: 150,
                            spacing: 10,
                            children: [
                              AppButton(
                                fullWidth: true,
                                variant: AppButtonVariant.outlined,
                                onPressed: () => context.push('/login'),
                                child: const Text('Кирүү'),
                              ),
                              AppButton(
                                fullWidth: true,
                                variant: AppButtonVariant.outlined,
                                onPressed: () => context.push('/signup'),
                                child: const Text('Катталуу'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalChoice extends ConsumerWidget {
  const _GoalChoice({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).dailyGoalMinutes == minutes;

    return ChoiceChip(
      label: Text('$minutes мүн'),
      selected: selected,
      onSelected: (_) =>
          ref.read(onboardingProvider).setDailyGoalMinutes(minutes),
    );
  }
}
