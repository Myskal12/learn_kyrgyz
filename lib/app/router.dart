import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/extras/presentation/achievements_screen.dart';
import '../features/extras/presentation/resources_screen.dart';
import '../features/extras/presentation/study_plan_screen.dart';
import '../features/learning/presentation/flashcard_screen.dart';
import '../features/profile/presentation/leaderboard_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/profile_settings_screen.dart';
import '../features/quiz/presentation/quiz_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(
      path: '/categories',
      builder: (context, state) => CategoriesScreen(),
    ),
    GoRoute(
      path: '/flashcards/:categoryId',
      builder: (context, state) =>
          FlashcardScreen(categoryId: state.pathParameters['categoryId']!),
    ),
    GoRoute(
      path: '/quiz/:categoryId',
      builder: (context, state) =>
          QuizScreen(categoryId: state.pathParameters['categoryId']!),
    ),
    GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const ProfileSettingsScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/study-plan',
      builder: (context, state) => const StudyPlanScreen(),
    ),
    GoRoute(
      path: '/resources',
      builder: (context, state) => const ResourcesScreen(),
    ),
    GoRoute(
      path: '/quick-quiz',
      builder: (context, state) => const QuizScreen(categoryId: ''),
    ),
  ],
);
