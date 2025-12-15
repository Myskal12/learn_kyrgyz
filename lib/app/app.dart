import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/providers/learning_session_provider.dart';
import '../core/services/firebase_service.dart';
import '../core/services/local_storage_service.dart';
import '../core/utils/app_colors.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/categories/providers/categories_provider.dart';
import '../features/learning/providers/flashcard_provider.dart';
import '../features/learning/repository/sentences_repository.dart';
import '../features/learning/repository/words_repository.dart';
import '../features/profile/providers/progress_provider.dart';
import '../features/profile/providers/user_profile_provider.dart';
import '../features/quiz/repository/quiz_repository.dart';
import '../features/quiz/providers/quiz_provider.dart';
import 'router.dart';

class App extends StatelessWidget {
  App({super.key});

  final FirebaseService firebaseService = FirebaseService();
  final LocalStorageService localStorageService = LocalStorageService();

  @override
  Widget build(BuildContext context) {
    final wordsRepo = WordsRepository(firebaseService);
    final sentencesRepo = SentencesRepository(firebaseService);
    final quizRepo = QuizRepository(firebaseService, wordsRepo);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: AppColors.background,
    );

    return MultiProvider(
      providers: [
        Provider<FirebaseService>.value(value: firebaseService),
        Provider<LocalStorageService>.value(value: localStorageService),
        Provider<WordsRepository>.value(value: wordsRepo),
        Provider<SentencesRepository>.value(value: sentencesRepo),
        ChangeNotifierProvider(
          create: (_) => LearningSessionProvider(localStorageService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProgressProvider(localStorageService, firebaseService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              UserProfileProvider(firebaseService, localStorageService),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider(firebaseService)),
        ChangeNotifierProvider(
          create: (_) => CategoriesProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FlashcardProvider(
            wordsRepo,
            ctx.read<SentencesRepository>(),
            ctx.read<ProgressProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              QuizProvider(quizRepo, wordsRepo, ctx.read<ProgressProvider>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'LearnKyrgyz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.manropeTextTheme().apply(
            bodyColor: AppColors.textDark,
            displayColor: AppColors.textDark,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(color: AppColors.muted.withValues(alpha: 0.35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.textDark,
            elevation: 0,
            centerTitle: false,
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}
