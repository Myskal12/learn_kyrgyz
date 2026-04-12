import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'app_bottom_nav.dart' show AppTab;

import '../../core/localization/app_copy.dart';
import '../../core/utils/app_colors.dart';
import 'app_pattern_background.dart';
import 'app_bottom_nav.dart';
import 'app_sidebar.dart';
import 'app_top_nav.dart';

enum AppShellNavigationMode { menu, back }

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
    this.navigationMode = AppShellNavigationMode.menu,
    this.backFallbackRoute,
  });

  final Widget child;
  final String title;
  final String? subtitle;
  final AppTopNavTone tone;
  final bool showTopNav;
  final bool showBottomNav;
  final AppTab activeTab;
  final AppShellNavigationMode navigationMode;
  final String? backFallbackRoute;

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

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    context.go(widget.backFallbackRoute ?? '/home');
  }

  void _handleTab(AppTab tab) {
    switch (tab) {
      case AppTab.learn:
        context.go('/home');
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
    // Match rendered nav sizes so page content never sits under overlays.
    const topNavContentHeight = 68.0;
    const bottomNavContentHeight = 84.0;

    final media = MediaQuery.of(context);
    final maxWidth = media.size.width >= 900
        ? 640.0
        : media.size.width >= 600
        ? 520.0
        : 430.0;
    final topPadding = widget.showTopNav
        ? media.padding.top + topNavContentHeight
        : media.padding.top;
    final bottomPadding = widget.showBottomNav
        ? media.padding.bottom + bottomNavContentHeight
        : media.padding.bottom;

    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AppPatternBackground()),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
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
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: AppTopNav(
                    title: widget.title,
                    subtitle:
                        widget.subtitle ??
                        context.tr(
                          ky: 'Интерфейс тили',
                          en: 'Interface language',
                          ru: 'Язык интерфейса',
                        ),
                    onLeadingTap:
                        widget.navigationMode == AppShellNavigationMode.back
                        ? _handleBack
                        : _openSidebar,
                    tone: widget.tone,
                    leadingType:
                        widget.navigationMode == AppShellNavigationMode.back
                        ? AppTopNavLeadingType.back
                        : AppTopNavLeadingType.menu,
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
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: AppBottomNav(
                    activeTab: widget.activeTab,
                    onTabSelected: _handleTab,
                  ),
                ),
              ),
            ),
          if (widget.navigationMode == AppShellNavigationMode.menu)
            AppSidebar(
              open: _sidebarOpen,
              currentLocation: GoRouterState.of(context).uri.path,
              onClose: _closeSidebar,
              onNavigate: _handleNavigate,
            ),
        ],
      ),
    );

    if (widget.navigationMode != AppShellNavigationMode.back) {
      return scaffold;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: scaffold,
    );
  }
}
