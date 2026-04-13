import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/localization/app_copy.dart';
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
      await ref
          .read(localStorageServiceProvider)
          .setString(Constants.postLogoutRedirectKey, 'false');
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
      await ref
          .read(localStorageServiceProvider)
          .setString(Constants.postLogoutRedirectKey, 'false');
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
                                    context.tr(
                                      ky: 'Биринчи күндөн баштаңыз',
                                      en: 'Start from day one',
                                      ru: 'Начните с первого дня',
                                    ),
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.tr(
                                    ky: 'Кыргызчаны жеңил жана сулуу ритм менен үйрөнүңүз',
                                    en: 'Learn Kyrgyz with an easy, beautiful rhythm',
                                    ru: 'Изучайте кыргызский в лёгком и красивом ритме',
                                  ),
                                  style: AppTextStyles.heading.copyWith(
                                    color: Colors.white,
                                    fontSize: 30,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  context.tr(
                                    ky: 'Максатты тандап, дароо баштаңыз.',
                                    en: 'Choose a goal and start right away.',
                                    ru: 'Выберите цель и начните сразу.',
                                  ),
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ValueCard(
                            icon: Icons.bolt,
                            title: context.tr(
                              ky: 'Тез башталат',
                              en: 'Starts fast',
                              ru: 'Быстрый старт',
                            ),
                            subtitle: context.tr(
                              ky: 'Биринчи сабакка түз өтөсүз.',
                              en: 'You go straight to the first lesson.',
                              ru: 'Вы сразу переходите к первому уроку.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ValueCard(
                            icon: Icons.menu_book,
                            title: context.tr(
                              ky: 'Кыска практика',
                              en: 'Short practice',
                              ru: 'Короткая практика',
                            ),
                            subtitle: context.tr(
                              ky: 'Карточка, квиз, сүйлөм бир жерде.',
                              en: 'Flashcards, quiz, and sentences in one place.',
                              ru: 'Карточки, квиз и предложения в одном месте.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ValueCard(
                            icon: Icons.cloud_done,
                            title: context.tr(
                              ky: 'Конок режими',
                              en: 'Guest mode',
                              ru: 'Гостевой режим',
                            ),
                            subtitle: context.tr(
                              ky: 'Азыр баштап, кийин кире аласыз.',
                              en: 'Start now and sign in later.',
                              ru: 'Начните сейчас, а войдёте позже.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            context.tr(
                              ky: 'Күндүк максат',
                              en: 'Daily goal',
                              ru: 'Дневная цель',
                            ),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr(
                              ky: 'Күнүнө канча убакыт бөлгүңүз келет?',
                              en: 'How much time do you want to spend per day?',
                              ru: 'Сколько времени вы хотите уделять в день?',
                            ),
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
                            context.tr(
                              ky: 'Кааласаңыз кийин өзгөртөсүз.',
                              en: 'You can change this later if you want.',
                              ru: 'При желании это можно изменить позже.',
                            ),
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
                                  context.tr(
                                    ky: 'Кирүү жолдору',
                                    en: 'Ways to continue',
                                    ru: 'Способы входа',
                                  ),
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.tr(
                                    ky: 'Кааласаңыз Google менен кириңиз.',
                                    en: 'You can continue with Google if you want.',
                                    ru: 'При желании можно продолжить через Google.',
                                  ),
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
                                  child: Text(
                                    context.tr(
                                      ky: 'Google менен улантуу',
                                      en: 'Continue with Google',
                                      ru: 'Продолжить с Google',
                                    ),
                                  ),
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
                              context.tr(
                                ky: 'Конок катары баштоо · $selectedGoal мүн',
                                en: 'Start as guest · $selectedGoal min',
                                ru: 'Начать как гость · $selectedGoal мин',
                              ),
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
                                child: Text(
                                  context.tr(
                                    ky: 'Кирүү',
                                    en: 'Sign in',
                                    ru: 'Войти',
                                  ),
                                ),
                              ),
                              AppButton(
                                fullWidth: true,
                                variant: AppButtonVariant.outlined,
                                onPressed: () => context.push('/signup'),
                                child: Text(
                                  context.tr(
                                    ky: 'Катталуу',
                                    en: 'Sign up',
                                    ru: 'Регистрация',
                                  ),
                                ),
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
      label: Text(
        context.tr(ky: '$minutes мүн', en: '$minutes min', ru: '$minutes мин'),
      ),
      selected: selected,
      onSelected: (_) =>
          ref.read(onboardingProvider).setDailyGoalMinutes(minutes),
    );
  }
}
