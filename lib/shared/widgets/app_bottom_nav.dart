import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';

enum AppTab { learn, practice, progress, profile }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  final AppTab activeTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _NavItem(
        tab: AppTab.learn,
        label: 'Үйрөнүү',
        shortLabel: 'Үйрөн',
        icon: Icons.school,
      ),
      _NavItem(
        tab: AppTab.practice,
        label: 'Практика',
        shortLabel: 'Практ.',
        icon: Icons.flash_on,
      ),
      _NavItem(
        tab: AppTab.progress,
        label: 'Прогресс',
        shortLabel: 'Прогр.',
        icon: Icons.bar_chart,
      ),
      _NavItem(
        tab: AppTab.profile,
        label: 'Профиль',
        shortLabel: 'Проф.',
        icon: Icons.person,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(11) / 11;
        final compact = constraints.maxWidth < 360 || textScale > 1.2;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            border: Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(31, 31, 31, 0.12),
                blurRadius: 24,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 16,
                vertical: compact ? 8 : 10,
              ),
              child: Row(
                children: tabs
                    .map(
                      (item) => Expanded(
                        child: _BottomNavButton(
                          item: item,
                          compact: compact,
                          isActive: activeTab == item.tab,
                          onTap: () => onTabSelected(item.tab),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.tab,
    required this.label,
    required this.shortLabel,
    required this.icon,
  });

  final AppTab tab;
  final String label;
  final String shortLabel;
  final IconData icon;
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.item,
    required this.compact,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool compact;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.textDark : AppColors.muted;
    final background = isActive
        ? AppColors.primary.withValues(alpha: 0.2)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 12,
            vertical: compact ? 8 : 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 24, color: color),
              const SizedBox(height: 6),
              Text(
                compact ? item.shortLabel : item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
