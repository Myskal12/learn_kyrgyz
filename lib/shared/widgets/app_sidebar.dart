import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../core/localization/app_copy.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/profile/providers/user_profile_provider.dart';
import 'app_card.dart';
import 'profile_avatar.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.open,
    required this.currentLocation,
    required this.onClose,
    required this.onNavigate,
  });

  final bool open;
  final String currentLocation;
  final VoidCallback onClose;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProvider = ref.watch(userProfileProvider);
    final isGuest = profileProvider.isGuest;
    final profile = profileProvider.profile;
    final displayName = isGuest
        ? context.tr(ky: 'Конок', en: 'Guest', ru: 'Гость')
        : profile.nickname;
    final subtitle = isGuest
        ? context.tr(ky: 'Конок режими', en: 'Guest mode', ru: 'Гостевой режим')
        : context.tr(
            ky: 'Окуу профили',
            en: 'Learning profile',
            ru: 'Учебный профиль',
          );
    final avatar = isGuest ? profile.avatar : profile.avatar;

    final destinations = [
      _SidebarItem(
        context.tr(ky: 'Башкы бет', en: 'Home', ru: 'Главная'),
        Icons.home,
        '/home',
      ),
      _SidebarItem(
        context.tr(ky: 'Сабактар', en: 'Lessons', ru: 'Уроки'),
        Icons.layers,
        '/categories',
      ),
      _SidebarItem(
        context.tr(ky: 'Практика', en: 'Practice', ru: 'Практика'),
        Icons.flash_on,
        '/practice',
      ),
      _SidebarItem(
        context.tr(ky: 'Карточкалар', en: 'Flashcards', ru: 'Карточки'),
        Icons.menu_book,
        '/flashcards',
      ),
      _SidebarItem(
        context.tr(
          ky: 'Сүйлөм түзүү',
          en: 'Sentence builder',
          ru: 'Сборка фраз',
        ),
        Icons.text_fields,
        '/sentence-builder',
      ),
      _SidebarItem(
        context.tr(ky: 'Квиз', en: 'Quiz', ru: 'Квиз'),
        Icons.check_circle,
        '/quiz',
      ),
      _SidebarItem(
        context.tr(ky: 'Прогресс', en: 'Progress', ru: 'Прогресс'),
        Icons.bar_chart,
        '/progress',
      ),
      _SidebarItem(
        context.tr(ky: 'Жетишкендиктер', en: 'Achievements', ru: 'Достижения'),
        Icons.workspace_premium,
        '/achievements',
      ),
      _SidebarItem(
        context.tr(ky: 'Рейтинг', en: 'Leaderboard', ru: 'Рейтинг'),
        Icons.emoji_events,
        '/leaderboard',
      ),
      _SidebarItem(
        context.tr(ky: 'Жол картасы', en: 'Roadmap', ru: 'Дорожная карта'),
        Icons.calendar_month,
        '/categories',
      ),
      _SidebarItem(
        context.tr(ky: 'Ресурстар', en: 'Resources', ru: 'Ресурсы'),
        Icons.open_in_new,
        '/resources',
      ),
      _SidebarItem(
        context.tr(ky: 'Профиль', en: 'Profile', ru: 'Профиль'),
        Icons.person,
        '/profile',
      ),
      _SidebarItem(
        context.tr(ky: 'Жөндөөлөр', en: 'Settings', ru: 'Настройки'),
        Icons.settings,
        '/settings',
      ),
    ];

    final accountItems = isGuest
        ? [
            _SidebarItem(
              context.tr(ky: 'Кирүү', en: 'Sign in', ru: 'Войти'),
              Icons.login,
              '/login',
            ),
            _SidebarItem(
              context.tr(ky: 'Катталуу', en: 'Sign up', ru: 'Регистрация'),
              Icons.person_add,
              '/signup',
            ),
          ]
        : const <_SidebarItem>[];

    return Stack(
      children: [
        IgnorePointer(
          ignoring: !open,
          child: AnimatedOpacity(
            opacity: open ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: onClose,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          left: open ? 0 : -280,
          top: 0,
          bottom: 0,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: AppColors.sidebar,
              border: Border(right: BorderSide(color: AppColors.sidebarBorder)),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(31, 31, 31, 0.18),
                  blurRadius: 48,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(
                                ky: 'Тандалган тил',
                                en: 'Selected language',
                                ru: 'Выбранный язык',
                              ),
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.appLanguage.nativeLabel,
                              style: AppTextStyles.title,
                            ),
                          ],
                        ),
                        _SidebarIconButton(icon: Icons.close, onTap: onClose),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ProfileAvatar(avatar: avatar, size: 48),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName, style: AppTextStyles.title),
                                const SizedBox(height: 2),
                                Text(subtitle, style: AppTextStyles.muted),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        ...destinations.map((item) {
                          final active = _isActive(item.route);
                          return _SidebarNavButton(
                            label: item.label,
                            icon: item.icon,
                            active: active,
                            onTap: () => onNavigate(item.route),
                          );
                        }),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            context.tr(
                              ky: 'АККАУНТ',
                              en: 'ACCOUNT',
                              ru: 'АККАУНТ',
                            ),
                            style: AppTextStyles.caption.copyWith(
                              letterSpacing: 2.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...accountItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: AppCard(
                              radius: AppCardRadius.md,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              onTap: () => onNavigate(item.route),
                              child: Row(
                                children: [
                                  Icon(item.icon, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.label,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!isGuest)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: AppCard(
                              radius: AppCardRadius.md,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              onTap: () async {
                                await ref.read(authProvider).logout();
                                await ref
                                    .read(localStorageServiceProvider)
                                    .setString(
                                      Constants.postLogoutRedirectKey,
                                      'true',
                                    );
                                onNavigate('/login');
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    size: 20,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    context.tr(
                                      ky: 'Чыгуу',
                                      en: 'Sign out',
                                      ru: 'Выйти',
                                    ),
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isActive(String route) {
    if (route == '/home') {
      return currentLocation == '/home';
    }
    return currentLocation.startsWith(route);
  }
}

class _SidebarItem {
  const _SidebarItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class _SidebarIconButton extends StatelessWidget {
  const _SidebarIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _SidebarNavButton extends StatelessWidget {
  const _SidebarNavButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.textDark : AppColors.muted;
    final background = active
        ? AppColors.primary.withValues(alpha: 0.2)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
