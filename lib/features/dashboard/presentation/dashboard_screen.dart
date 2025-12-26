import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../practice/presentation/practice_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;

  final _tabs = const [
    HomeScreen(),
    CategoriesScreen(showAppBar: false),
    PracticeScreen(),
    ProfileScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Башкы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Сабактар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science_rounded),
            label: 'Практика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
