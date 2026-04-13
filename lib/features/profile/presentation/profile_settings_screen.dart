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

enum SettingsViewMode { all, profile, security, interface }

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    this.initialSection,
    this.viewMode = SettingsViewMode.all,
    this.backFallbackRoute = '/profile',
  });

  final String? initialSection;
  final SettingsViewMode viewMode;
  final String backFallbackRoute;

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final GlobalKey _accountSectionKey = GlobalKey();
  final GlobalKey _learningSectionKey = GlobalKey();
  final GlobalKey _interfaceSectionKey = GlobalKey();
  final GlobalKey _privacySectionKey = GlobalKey();
  final GlobalKey _dangerSectionKey = GlobalKey();
  bool _didHandleInitialSection = false;

  bool get _showAccountSection =>
      widget.viewMode == SettingsViewMode.all ||
      widget.viewMode == SettingsViewMode.profile;

  bool get _showLearningSection => widget.viewMode == SettingsViewMode.all;

  bool get _showInterfaceSection =>
      widget.viewMode == SettingsViewMode.all ||
      widget.viewMode == SettingsViewMode.interface;

  bool get _showPrivacySection =>
      widget.viewMode == SettingsViewMode.all ||
      widget.viewMode == SettingsViewMode.security;

  bool get _showDangerSection =>
      widget.viewMode == SettingsViewMode.all ||
      widget.viewMode == SettingsViewMode.security;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeScrollToInitialSection();
  }

  @override
  void didUpdateWidget(covariant ProfileSettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      _didHandleInitialSection = false;
      _maybeScrollToInitialSection();
    }
  }

  void _maybeScrollToInitialSection() {
    if (_didHandleInitialSection) return;
    _didHandleInitialSection = true;

    final targetKey = _resolveSectionKey(widget.initialSection);
    if (targetKey == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sectionContext = targetKey.currentContext;
      if (sectionContext == null) return;
      Scrollable.ensureVisible(
        sectionContext,
        alignment: 0.06,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  GlobalKey? _resolveSectionKey(String? section) {
    final value = section?.trim().toLowerCase();
    switch (value) {
      case 'account':
      case 'email':
      case 'profile':
        return _accountSectionKey;
      case 'learning':
      case 'study':
        return _learningSectionKey;
      case 'interface':
      case 'appearance':
      case 'theme':
      case 'color':
        return _interfaceSectionKey;
      case 'privacy':
      case 'legal':
        return _privacySectionKey;
      case 'danger':
      case 'reset':
        return _dangerSectionKey;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final progress = ref.watch(progressProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appLanguage = ref.watch(appLanguageProvider);
    final direction = ref.watch(learningDirectionProvider);
    final profileProvider = ref.watch(userProfileProvider);
    final auth = ref.watch(authProvider);

    final themeLabel = themeMode == ThemeMode.dark
        ? context.tr(ky: 'Караңгы', en: 'Dark', ru: 'Тёмная')
        : context.tr(ky: 'Жарык', en: 'Light', ru: 'Светлая');

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
      backFallbackRoute: widget.backFallbackRoute,
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
          if (_showAccountSection) ...[
            _SectionCard(
              key: _accountSectionKey,
              icon: Icons.person_rounded,
              color: AppColors.primary,
              title: context.tr(ky: 'Аккаунт', en: 'Account', ru: 'Аккаунт'),
              subtitle: context.tr(
                ky: 'Профиль, email жана кирүү абалы',
                en: 'Profile, email and sign-in status',
                ru: 'Профиль, email и статус входа',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsRow(
                    title: context.tr(
                      ky: 'Профиль',
                      en: 'Profile',
                      ru: 'Профиль',
                    ),
                    value: accountTitle,
                    action: profileProvider.isGuest
                        ? _InlineAction(
                            label: context.tr(
                              ky: 'Кирүү',
                              en: 'Sign in',
                              ru: 'Войти',
                            ),
                            onTap: () => context.go('/login'),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    title: context.tr(ky: 'Статус', en: 'Status', ru: 'Статус'),
                    value: accountSubtitle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr(ky: 'Аватар', en: 'Avatar', ru: 'Аватар'),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (profileProvider.isGuest)
                    AvatarSelectionHint(
                      text: context.tr(
                        ky: 'Аватар аккаунт ачкандан кийин сакталат.',
                        en: 'Avatar will be saved after you create an account.',
                        ru: 'Аватар сохранится после создания аккаунта.',
                      ),
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
                        !profileProvider.isGuest &&
                            auth.requiresEmailVerification
                        ? _InlineAction(
                            label: context.tr(
                              ky: 'Ырастоо',
                              en: 'Verify',
                              ru: 'Подтвердить',
                            ),
                            onTap: () => context.push(
                              '/verify-email?returnTo=/settings/profile',
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    title: context.tr(
                      ky: 'Email абалы',
                      en: 'Email status',
                      ru: 'Статус email',
                    ),
                    value: emailStatus,
                    action:
                        !profileProvider.isGuest &&
                            auth.requiresEmailVerification
                        ? _InlineAction(
                            label: context.tr(
                              ky: 'Кайра жиберүү',
                              en: 'Resend',
                              ru: 'Отправить снова',
                            ),
                            onTap: () => _resendVerification(context, ref),
                          )
                        : null,
                  ),
                  if (!profileProvider.isGuest &&
                      auth.requiresEmailVerification)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        context.tr(
                          ky: 'Email ырастоосу сунушталат, бирок аны кийинчерээк да бүтүрсөңүз болот.',
                          en: 'Email verification is recommended, but you can complete it later.',
                          ru: 'Подтверждение email рекомендуется, но его можно завершить позже.',
                        ),
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
                            child: Text(
                              context.tr(
                                ky: 'Кирүү',
                                en: 'Sign in',
                                ru: 'Войти',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            fullWidth: true,
                            variant: AppButtonVariant.outlined,
                            onPressed: () => context.go('/signup'),
                            child: Text(
                              context.tr(
                                ky: 'Катталуу',
                                en: 'Sign up',
                                ru: 'Регистрация',
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    AppButton(
                      fullWidth: true,
                      variant: AppButtonVariant.outlined,
                      onPressed: () => _signOut(context, ref),
                      child: Text(
                        context.tr(ky: 'Чыгуу', en: 'Log out', ru: 'Выйти'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_showLearningSection) ...[
            _SectionCard(
              key: _learningSectionKey,
              icon: Icons.menu_book_rounded,
              color: AppColors.accent,
              title: context.tr(ky: 'Окуу', en: 'Learning', ru: 'Обучение'),
              subtitle: context.tr(
                ky: 'Темп жана окуу багыты',
                en: 'Pace and learning direction',
                ru: 'Темп и направление обучения',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsRow(
                    title: context.tr(
                      ky: 'Күндүк максат',
                      en: 'Daily goal',
                      ru: 'Дневная цель',
                    ),
                    value: context.tr(
                      ky: '${onboarding.dailyGoalMinutes} мүнөт',
                      en: '${onboarding.dailyGoalMinutes} minutes',
                      ru: '${onboarding.dailyGoalMinutes} минут',
                    ),
                    action: _InlineAction(
                      label: context.tr(
                        ky: 'Өзгөртүү',
                        en: 'Change',
                        ru: 'Изменить',
                      ),
                      onTap: () => _showDailyGoalPicker(context, ref),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    title: context.tr(
                      ky: 'Окуу багыты',
                      en: 'Learning direction',
                      ru: 'Направление обучения',
                    ),
                    value: direction.helperTextOf(context),
                    action: _InlineAction(
                      label: context.tr(
                        ky: 'Алмаштыруу',
                        en: 'Switch',
                        ru: 'Сменить',
                      ),
                      onTap: () => ref
                          .read(learningDirectionProvider.notifier)
                          .toggleDirection(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    title: context.tr(
                      ky: 'Прогресс сактоо',
                      en: 'Progress sync',
                      ru: 'Синхронизация прогресса',
                    ),
                    value: progress.syncSubtitleOf(context),
                    action: progress.canRetrySync
                        ? _InlineAction(
                            label: context.tr(
                              ky: 'Кайра синк',
                              en: 'Retry sync',
                              ru: 'Повторить синхронизацию',
                            ),
                            onTap: progress.retrySync,
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_showInterfaceSection) ...[
            _SectionCard(
              key: _interfaceSectionKey,
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
                      onTap: () =>
                          _showLanguagePicker(context, ref, appLanguage),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_showPrivacySection) ...[
            _SectionCard(
              key: _privacySectionKey,
              icon: Icons.shield_outlined,
              color: AppColors.success,
              title: context.tr(
                ky: 'Купуялык жана укуктук маалымат',
                en: 'Privacy and legal info',
                ru: 'Приватность и правовая информация',
              ),
              subtitle: context.tr(
                ky: 'Маалымат колдонулушу жана негизги документтер',
                en: 'Data usage and key documents',
                ru: 'Использование данных и ключевые документы',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsRow(
                    title: context.tr(
                      ky: 'Лидерборд',
                      en: 'Leaderboard',
                      ru: 'Лидерборд',
                    ),
                    value: profileProvider.isGuest
                        ? context.tr(
                            ky: 'Конок режиминде рейтингге катышуу жок.',
                            en: 'Guest mode does not participate in the leaderboard.',
                            ru: 'Гостевой режим не участвует в лидерборде.',
                          )
                        : context.tr(
                            ky: 'Статистика лидерборд жана профилде көрүнүшү мүмкүн.',
                            en: 'Some stats may appear in the leaderboard and profile.',
                            ru: 'Часть статистики может отображаться в лидерборде и профиле.',
                          ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    title: context.tr(
                      ky: 'Купуялык саясаты',
                      en: 'Privacy policy',
                      ru: 'Политика конфиденциальности',
                    ),
                    value: context.tr(
                      ky: 'Колдонмодо кандай маалымат сакталары түшүндүрүлөт.',
                      en: 'Explains what data is stored in the app.',
                      ru: 'Объясняет, какие данные хранятся в приложении.',
                    ),
                    action: _InlineAction(
                      label: context.tr(ky: 'Ачуу', en: 'Open', ru: 'Открыть'),
                      onTap: () => context.push('/privacy-policy'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    title: context.tr(
                      ky: 'Колдонуу шарттары',
                      en: 'Terms of use',
                      ru: 'Условия использования',
                    ),
                    value: context.tr(
                      ky: 'Колдонуу шарттары жана жоопкерчилик чек арасы.',
                      en: 'Usage terms and responsibility boundaries.',
                      ru: 'Условия использования и границы ответственности.',
                    ),
                    action: _InlineAction(
                      label: context.tr(ky: 'Ачуу', en: 'Open', ru: 'Открыть'),
                      onTap: () => context.push('/terms-of-use'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_showDangerSection)
            _SectionCard(
              key: _dangerSectionKey,
              icon: Icons.warning_amber_rounded,
              color: AppColors.accent,
              title: context.tr(
                ky: 'Маанилүү аракеттер',
                en: 'Critical actions',
                ru: 'Важные действия',
              ),
              subtitle: context.tr(
                ky: 'Бул аракеттерди артка кайтаруу мүмкүн эмес',
                en: 'These actions cannot be undone',
                ru: 'Эти действия нельзя отменить',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      ky: 'Прогрессти тазалоо бардык локалдуу жана аккаунтка байланышкан окуу жыйынтыктарын өчүрөт.',
                      en: 'Resetting progress removes all local and account-linked learning results.',
                      ru: 'Сброс прогресса удалит все локальные и связанные с аккаунтом результаты обучения.',
                    ),
                    style: AppTextStyles.muted,
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    variant: AppButtonVariant.danger,
                    fullWidth: true,
                    onPressed: () => _confirmResetProgress(context, ref),
                    child: Text(
                      context.tr(
                        ky: 'Прогрессти өчүрүү',
                        en: 'Reset progress',
                        ru: 'Сбросить прогресс',
                      ),
                    ),
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
        SnackBar(
          content: Text(
            context.tr(
              ky: 'Ырастоо каты кайра жөнөтүлдү.',
              en: 'Verification email was sent again.',
              ru: 'Письмо для подтверждения отправлено повторно.',
            ),
          ),
        ),
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
          title: Text(
            context.tr(
              ky: 'Прогрессти өчүрөсүзбү?',
              en: 'Reset progress?',
              ru: 'Сбросить прогресс?',
            ),
          ),
          content: Text(
            context.tr(
              ky: 'Бул аракеттен кийин статистика, streak жана үйрөнүлгөн сөздөр тазаланат.',
              en: 'After this action, stats, streak, and learned words will be cleared.',
              ru: 'После этого действия статистика, серия и выученные слова будут очищены.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                context.tr(ky: 'Жокко чыгаруу', en: 'Cancel', ru: 'Отмена'),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                context.tr(ky: 'Өчүрүү', en: 'Reset', ru: 'Сбросить'),
              ),
            ),
          ],
        );
      },
    );

    if (approved != true || !context.mounted) return;
    await ref.read(progressProvider).reset();
    await ref.read(userProfileProvider).refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            ky: 'Прогресс тазаланды.',
            en: 'Progress was cleared.',
            ru: 'Прогресс очищен.',
          ),
        ),
      ),
    );
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
              Text(
                context.tr(
                  ky: 'Күндүк максат',
                  en: 'Daily goal',
                  ru: 'Дневная цель',
                ),
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  ky: 'Сизге ыңгайлуу темпти тандаңыз.',
                  en: 'Choose a pace that works for you.',
                  ru: 'Выберите комфортный для себя темп.',
                ),
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
                  title: Text(
                    context.tr(
                      ky: '$minutes мүнөт',
                      en: '$minutes minutes',
                      ru: '$minutes минут',
                    ),
                  ),
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
    super.key,
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
