import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'app_bottom_nav.dart' show AppTab;

import '../../core/utils/app_colors.dart';
import 'app_bottom_nav.dart';
import 'app_sidebar.dart';
import 'app_top_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.tone = AppTopNavTone.light,
    this.showTopNav = true,
    this.showBottomNav = true,
    this.activeTab = AppTab.learn,
  });

  final Widget child;
  final String title;
  final String? subtitle;
  final AppTopNavTone tone;
  final bool showTopNav;
  final bool showBottomNav;
  final AppTab activeTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarOpen = false;

  void _openSidebar() {
    setState(() => _sidebarOpen = true);
  }

  void _closeSidebar() {
    setState(() => _sidebarOpen = false);
  }

  void _handleNavigate(String route) {
    _closeSidebar();
    context.go(route);
  }

  void _handleTab(AppTab tab) {
    switch (tab) {
      case AppTab.learn:
        context.go('/');
        break;
      case AppTab.practice:
        context.go('/practice');
        break;
      case AppTab.progress:
        context.go('/progress');
        break;
      case AppTab.profile:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 390.0;
    const topNavContentHeight = 64.0;
    const bottomNavContentHeight = 62.0;

    final media = MediaQuery.of(context);
    final topPadding = widget.showTopNav
        ? media.padding.top + topNavContentHeight
        : media.padding.top;
    final bottomPadding = widget.showBottomNav
        ? media.padding.bottom + bottomNavContentHeight
        : media.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  color: AppColors.background,
                  padding: EdgeInsets.only(
                    top: topPadding,
                    bottom: bottomPadding,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
          if (widget.showTopNav)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxWidth),
                  child: AppTopNav(
                    title: widget.title,
                    subtitle: widget.subtitle ?? 'Кыргызча / English',
                    onMenuTap: _openSidebar,
                    tone: widget.tone,
                  ),
                ),
              ),
            ),
          if (widget.showBottomNav)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxWidth),
                  child: AppBottomNav(
                    activeTab: widget.activeTab,
                    onTabSelected: _handleTab,
                  ),
                ),
              ),
            ),
          AppSidebar(
            open: _sidebarOpen,
            currentLocation: GoRouterState.of(context).uri.path,
            onClose: _closeSidebar,
            onNavigate: _handleNavigate,
          ),
        ],
      ),
    );
  }
}
