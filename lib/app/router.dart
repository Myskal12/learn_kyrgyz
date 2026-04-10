import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/auth_complete_screen.dart';
import '../features/auth/presentation/email_verification_screen.dart';
import '../features/auth/presentation/profile_setup_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/extras/presentation/achievements_screen.dart';
import '../features/extras/presentation/resources_screen.dart';
import '../features/extras/presentation/study_plan_screen.dart';
import '../features/learning/presentation/flashcard_screen.dart';
import '../features/learning/presentation/sentence_builder_screen.dart';
import '../features/learning/providers/flashcard_provider.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/profile/presentation/leaderboard_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/profile_settings_screen.dart';
import '../features/quiz/presentation/quiz_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/launch_gate_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/practice/presentation/practice_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LaunchGateScreen()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/auth-complete',
      builder: (context, state) => const AuthCompleteScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const EmailVerificationScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/practice',
      builder: (context, state) => const PracticeScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(path: '/lesson', redirect: (_, __) => '/practice'),
    GoRoute(
      path: '/flashcards',
      builder: (context, state) => FlashcardScreen(
        categoryId: 'basic',
        mode: _flashcardModeFromState(state),
      ),
    ),
    GoRoute(
      path: '/flashcards/:categoryId',
      builder: (context, state) => FlashcardScreen(
        categoryId: state.pathParameters['categoryId']!,
        mode: _flashcardModeFromState(state),
      ),
    ),
    GoRoute(
      path: '/sentence-builder',
      builder: (context, state) =>
          const SentenceBuilderScreen(categoryId: 'basic'),
    ),
    GoRoute(
      path: '/sentence-builder/:categoryId',
      builder: (context, state) => SentenceBuilderScreen(
        categoryId: state.pathParameters['categoryId']!,
      ),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizScreen(categoryId: 'basic'),
    ),
    GoRoute(
      path: '/quiz/:categoryId',
      builder: (context, state) =>
          QuizScreen(categoryId: state.pathParameters['categoryId']!),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
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
      path: '/roadmap',
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

FlashcardSessionMode _flashcardModeFromState(GoRouterState state) {
  return state.uri.queryParameters['mode'] == 'review'
      ? FlashcardSessionMode.reviewDue
      : FlashcardSessionMode.fullDeck;
}
