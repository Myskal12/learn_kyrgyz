import 'package:flutter/material.dart';

import 'app_language.dart';

class AppCopy {
  const AppCopy._();

  static AppLanguage languageOf(BuildContext context) {
    return AppLanguage.fromCode(Localizations.localeOf(context).languageCode);
  }

  static String text(
    BuildContext context, {
    required String ky,
    String? en,
    String? ru,
  }) {
    switch (languageOf(context)) {
      case AppLanguage.english:
        return en ?? ky;
      case AppLanguage.russian:
        return ru ?? ky;
      case AppLanguage.kyrgyz:
        return ky;
    }
  }
}

extension AppCopyContext on BuildContext {
  AppLanguage get appLanguage => AppCopy.languageOf(this);

  String tr({required String ky, String? en, String? ru}) {
    return AppCopy.text(this, ky: ky, en: en, ru: ru);
  }
}
