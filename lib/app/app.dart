import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_language.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import '../core/utils/app_colors.dart';
import '../theme/app_theme.dart';
import 'router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appLanguage = ref.watch(appLanguageProvider);

    return MaterialApp.router(
      title: 'LearnKyrgyz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: appLanguage.locale,
      supportedLocales: AppLanguage.values
          .map((language) => language.locale)
          .toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        AppColors.setDark(Theme.of(context).brightness == Brightness.dark);
        return child ?? const SizedBox.shrink();
      },
      routerConfig: router,
    );
  }
}
