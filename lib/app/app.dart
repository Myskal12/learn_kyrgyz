import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/services/firebase_service.dart';
import '../core/services/local_storage_service.dart';
import '../core/utils/app_colors.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/categories/providers/categories_provider.dart';
import '../features/learning/providers/flashcard_provider.dart';
import '../features/learning/repository/words_repository.dart';
import '../features/profile/providers/progress_provider.dart';
import '../features/quiz/providers/quiz_provider.dart';
import 'router.dart';

class App extends StatelessWidget {
  App({super.key});

  final FirebaseService firebaseService = FirebaseService();
  final LocalStorageService localStorageService = LocalStorageService();

  @override
  Widget build(BuildContext context) {
    final wordsRepo = WordsRepository(firebaseService);

    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.primary);

    return MultiProvider(
      providers: [
        Provider<FirebaseService>.value(value: firebaseService),
        Provider<LocalStorageService>.value(value: localStorageService),
        Provider<WordsRepository>.value(value: wordsRepo),
        ChangeNotifierProvider(create: (_) => ProgressProvider(localStorageService)..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) => CategoriesProvider(firebaseService)),
        ChangeNotifierProvider(
          create: (ctx) => FlashcardProvider(wordsRepo, ctx.read<ProgressProvider>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => QuizProvider(wordsRepo, ctx.read<ProgressProvider>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'LearnKyrgyz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme.copyWith(surface: AppColors.bg),
          scaffoldBackgroundColor: AppColors.bg,
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
