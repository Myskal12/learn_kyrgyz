import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_colors.dart';
import '../../../app/providers/navigation_provider.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../practice/presentation/practice_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);
    final tabs = const [
      CategoriesScreen(showAppBar: false),
      PracticeScreen(),
      HomeScreen(),
      ProfileScreen(embedded: true),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) =>
            ref.read(bottomNavIndexProvider.notifier).state = value,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
