import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/learning_direction_provider.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../app/providers/language_provider.dart';
import '../../../app/providers/theme_provider.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../shared/widgets/app_shell.dart';
import '../providers/progress_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final progress = ref.watch(progressProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appLanguage = ref.watch(appLanguageProvider);
    final direction = ref.watch(learningDirectionProvider);
    final profileProvider = ref.watch(userProfileProvider);
    final auth = ref.watch(authProvider);

    final themeLabel = themeMode == ThemeMode.dark
        ? context.tr(ky: 'Караңгы', en: 'Dark', ru: 'Тёмная')
        : themeMode == ThemeMode.light
        ? context.tr(ky: 'Жарык', en: 'Light', ru: 'Светлая')
        : context.tr(ky: 'Авто', en: 'Auto', ru: 'Авто');

    final accountTitle = profileProvider.isGuest
        ? context.tr(ky: 'Конок режими', en: 'Guest mode', ru: 'Гостевой режим')
        : profileProvider.profile.nickname;
    final accountSubtitle = profileProvider.isGuest
        ? context.tr(
            ky: 'Маалымат ушул түзмөктө гана сакталат.',
            en: 'Data is stored only on this device.',
            ru: 'Данные хранятся только на этом устройстве.',
          )
        : context.tr(
            ky: 'Аккаунт жана жеке маалыматты ушул жерден башкарасыз.',
            en: 'Manage account and personal data here.',
            ru: 'Управляйте аккаунтом и личными данными здесь.',
          );
    final emailLabel = auth.currentUserEmail?.trim().isNotEmpty == true
        ? auth.currentUserEmail!.trim()
        : context.tr(
            ky: 'Email кошулган эмес',
            en: 'No email added',
            ru: 'Email не добавлен',
          );
    final emailStatus = profileProvider.isGuest
        ? context.tr(ky: 'Аккаунт жок', en: 'No account', ru: 'Нет аккаунта')
        : auth.requiresEmailVerification
        ? context.tr(
            ky: 'Ырастоо күтүлүүдө',
            en: 'Verification pending',
            ru: 'Ожидает подтверждения',
          )
        : context.tr(
            ky: 'Ырасталган же талап кылынбайт',
            en: 'Verified or not required',
            ru: 'Подтверждено или не требуется',
          );

    return AppShell(
      title: context.tr(ky: 'Жөндөөлөр', en: 'Settings', ru: 'Настройки'),
      subtitle: context.tr(
        ky: 'Аккаунт, интерфейс жана купуялык',
        en: 'Account, interface and privacy',
        ru: 'Аккаунт, интерфейс и приватность',
      ),
      activeTab: AppTab.profile,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/profile',
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Text(
            context.tr(ky: 'Жөндөөлөр', en: 'Settings', ru: 'Настройки'),
            style: AppTextStyles.heading.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr(
              ky: 'Бул экран аккаунт, окуу жана купуялык үчүн негизги башкаруу борбору.',
              en: 'This screen is the main control center for account, learning and privacy.',
              ru: 'Этот экран — главный центр управления аккаунтом, обучением и приватностью.',
            ),
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            icon: Icons.person_rounded,
            color: AppColors.primary,
            title: 'Аккаунт',
            subtitle: 'Профиль, email жана кирүү абалы',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsRow(
                  title: 'Профиль',
                  value: accountTitle,
                  action: profileProvider.isGuest
                      ? _InlineAction(
                          label: 'Кирүү',
                          onTap: () => context.go('/login'),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                _SettingsRow(title: 'Статус', value: accountSubtitle),
                const SizedBox(height: 10),
                Text(
                  'Аватар',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (profileProvider.isGuest)
                  const AvatarSelectionHint(
                    text: 'Аватар аккаунт ачкандан кийин сакталат.',
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAvatar(avatar: profileProvider.profile.avatar),
                      const SizedBox(height: 12),
                      AvatarPresetPicker(
                        selectedAvatar: profileProvider.profile.avatar,
                        onSelected: (value) {
                          ref.read(userProfileProvider).updateAvatar(value);
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                _SettingsRow(
                  title: 'Email',
                  value: emailLabel,
                  action:
                      !profileProvider.isGuest && auth.requiresEmailVerification
                      ? _InlineAction(
                          label: 'Ырастоо',
                          onTap: () =>
                              context.push('/verify-email?returnTo=/settings'),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  title: 'Email абалы',
                  value: emailStatus,
                  action:
                      !profileProvider.isGuest && auth.requiresEmailVerification
                      ? _InlineAction(
                          label: 'Кайра жиберүү',
                          onTap: () => _resendVerification(context, ref),
                        )
                      : null,
                ),
                if (!profileProvider.isGuest && auth.requiresEmailVerification)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Email ырастоосу сунушталат, бирок аны кийинчерээк да бүтүрсөңүз болот.',
                      style: AppTextStyles.muted.copyWith(fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 14),
                if (profileProvider.isGuest)
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          fullWidth: true,
                          onPressed: () => context.go('/login'),
                          child: const Text('Кирүү'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          fullWidth: true,
                          variant: AppButtonVariant.outlined,
                          onPressed: () => context.go('/signup'),
                          child: const Text('Катталуу'),
                        ),
                      ),
                    ],
                  )
                else
                  AppButton(
                    fullWidth: true,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => _signOut(context, ref),
                    child: const Text('Чыгуу'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.menu_book_rounded,
            color: AppColors.accent,
            title: 'Окуу',
            subtitle: 'Темп жана окуу багыты',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsRow(
                  title: 'Күндүк максат',
                  value: '${onboarding.dailyGoalMinutes} мүнөт',
                  action: _InlineAction(
                    label: 'Өзгөртүү',
                    onTap: () => _showDailyGoalPicker(context, ref),
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  title: 'Окуу багыты',
                  value: direction.helperText,
                  action: _InlineAction(
                    label: 'Алмаштыруу',
                    onTap: () => ref
                        .read(learningDirectionProvider.notifier)
                        .toggleDirection(),
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  title: 'Прогресс сактоо',
                  value: progress.syncSubtitle,
                  action: progress.canRetrySync
                      ? _InlineAction(
                          label: 'Кайра синк',
                          onTap: progress.retrySync,
                        )
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.palette_outlined,
            color: const Color(0xFF1976D2),
            title: context.tr(
              ky: 'Интерфейс',
              en: 'Interface',
              ru: 'Интерфейс',
            ),
            subtitle: context.tr(
              ky: 'Көрүнүш жана интерфейс тили',
              en: 'Appearance and interface language',
              ru: 'Вид и язык интерфейса',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsRow(
                  title: context.tr(ky: 'Тема', en: 'Theme', ru: 'Тема'),
                  value: themeLabel,
                  action: _InlineAction(
                    label: context.tr(
                      ky: 'Алмаштыруу',
                      en: 'Switch',
                      ru: 'Сменить',
                    ),
                    onTap: () =>
                        ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  title: context.tr(ky: 'Тил', en: 'Language', ru: 'Язык'),
                  value: appLanguage.nativeLabel,
                  action: _InlineAction(
                    label: context.tr(
                      ky: 'Тандоо',
                      en: 'Choose',
                      ru: 'Выбрать',
                    ),
                    onTap: () => _showLanguagePicker(context, ref, appLanguage),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.shield_outlined,
            color: AppColors.success,
            title: 'Купуялык жана укуктук маалымат',
            subtitle: 'Маалымат колдонулушу жана негизги документтер',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsRow(
                  title: 'Лидерборд',
                  value: profileProvider.isGuest
                      ? 'Конок режиминде рейтингге катышуу жок.'
                      : 'Статистика лидерборд жана профилде көрүнүшү мүмкүн.',
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  title: 'Купуялык саясаты',
                  value: 'Колдонмодо кандай маалымат сакталары түшүндүрүлөт.',
                  action: _InlineAction(
                    label: 'Ачуу',
                    onTap: () => context.push('/privacy-policy'),
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  title: 'Колдонуу шарттары',
                  value: 'Колдонуу шарттары жана жоопкерчилик чек арасы.',
                  action: _InlineAction(
                    label: 'Ачуу',
                    onTap: () => context.push('/terms-of-use'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.warning_amber_rounded,
            color: AppColors.accent,
            title: 'Маанилүү аракеттер',
            subtitle: 'Бул аракеттерди артка кайтаруу мүмкүн эмес',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Прогрессти тазалоо бардык локалдуу жана аккаунтка байланышкан окуу жыйынтыктарын өчүрөт.',
                  style: AppTextStyles.muted,
                ),
                const SizedBox(height: 14),
                AppButton(
                  variant: AppButtonVariant.danger,
                  fullWidth: true,
                  onPressed: () => _confirmResetProgress(context, ref),
                  child: const Text('Прогрессти өчүрүү'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resendVerification(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(authProvider).sendEmailVerification();
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ырастоо каты кайра жөнөтүлдү.')),
      );
      return;
    }
    final error = ref.read(authProvider).error;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref
        .read(localStorageServiceProvider)
        .setString(Constants.postLogoutRedirectKey, 'true');
    await ref.read(authProvider).logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  Future<void> _confirmResetProgress(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Прогрессти өчүрөсүзбү?'),
          content: const Text(
            'Бул аракеттен кийин статистика, streak жана үйрөнүлгөн сөздөр тазаланат.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Жокко чыгаруу'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Өчүрүү'),
            ),
          ],
        );
      },
    );

    if (approved != true || !context.mounted) return;
    await ref.read(progressProvider).reset();
    await ref.read(userProfileProvider).refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Прогресс тазаланды.')));
  }

  Future<void> _showDailyGoalPicker(BuildContext context, WidgetRef ref) async {
    final onboarding = ref.read(onboardingProvider);
    final current = onboarding.dailyGoalMinutes;
    final options = onboarding.dailyGoalOptions;
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('Күндүк максат', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(
                'Сизге ыңгайлуу темпти тандаңыз.',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 16),
              ...options.map((minutes) {
                final active = current == minutes;
                return ListTile(
                  leading: Icon(
                    active ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: active ? AppColors.primary : AppColors.muted,
                  ),
                  title: Text('$minutes мүнөт'),
                  onTap: () => Navigator.of(context).pop(minutes),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    await ref.read(onboardingProvider).setDailyGoalMinutes(selected);
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
  ) async {
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                context.tr(
                  ky: 'Интерфейс тили',
                  en: 'Interface language',
                  ru: 'Язык интерфейса',
                ),
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  ky: 'Колдонмодо кайсы тилди көргүңүз келсе, ошону тандаңыз.',
                  en: 'Choose the language you want to see in the app.',
                  ru: 'Выберите язык, который хотите видеть в приложении.',
                ),
                style: AppTextStyles.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...AppLanguage.values.map((language) {
                final active = language == current;
                return ListTile(
                  leading: Icon(
                    active ? Icons.check_circle : Icons.language,
                    color: active ? AppColors.primary : AppColors.muted,
                  ),
                  title: Text(language.nativeLabel),
                  subtitle: Text(language.label),
                  onTap: () => Navigator.of(context).pop(language),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    await ref.read(appLanguageProvider.notifier).setLanguage(selected);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleIcon(icon: icon, color: color),
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.title, required this.value, this.action});

  final String title;
  final String value;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.muted),
          ],
        );

        if (action == null) {
          return content;
        }

        if (constraints.maxWidth < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [content, const SizedBox(height: 10), action!],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: content),
            const SizedBox(width: 12),
            action!,
          ],
        );
      },
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.mutedSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
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
