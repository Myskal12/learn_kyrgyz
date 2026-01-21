import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';
import '../../features/profile/providers/user_profile_provider.dart';
import 'app_card.dart';

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
    final displayName = isGuest ? 'Guest' : profile.nickname;
    final subtitle = isGuest ? 'Guest mode' : 'Башталгыч деңгээл';
    final avatar = isGuest ? 'G' : profile.avatar;

    final destinations = [
      _SidebarItem('Башкы бет', Icons.home, '/'),
      _SidebarItem('Сабактар', Icons.layers, '/categories'),
      _SidebarItem('Практика', Icons.flash_on, '/practice'),
      _SidebarItem('Карточкалар', Icons.menu_book, '/flashcards'),
      _SidebarItem('Сүйлөм түзүү', Icons.text_fields, '/sentence-builder'),
      _SidebarItem('Квиз', Icons.check_circle, '/quiz'),
      _SidebarItem('Прогресс', Icons.bar_chart, '/progress'),
      _SidebarItem('Рейтинг', Icons.emoji_events, '/leaderboard'),
      _SidebarItem('Профиль', Icons.person, '/profile'),
      _SidebarItem('Жөндөөлөр', Icons.settings, '/settings'),
    ];

    final accountItems = [
      _SidebarItem('Кирүү', Icons.login, '/login'),
      _SidebarItem('Катталуу', Icons.person_add, '/signup'),
    ];

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
                              'Кыргызча / English',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 4),
                            Text('Learn Kyrgyz', style: AppTextStyles.title),
                          ],
                        ),
                        _SidebarIconButton(
                          icon: Icons.close,
                          onTap: onClose,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              avatar,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName, style: AppTextStyles.title),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: AppTextStyles.muted,
                                ),
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
                            'АККАУНТ',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AppCard(
                            radius: AppCardRadius.md,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            onTap: () => onNavigate('/login'),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: 20,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Чыгуу',
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
    if (route == '/') {
      return currentLocation == '/';
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
