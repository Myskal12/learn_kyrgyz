import 'package:flutter/material.dart';

enum AppLanguage {
  kyrgyz('ky', 'Кыргызча', 'Кыргызча'),
  english('en', 'English', 'English'),
  russian('ru', 'Русский', 'Русский');

  const AppLanguage(this.code, this.label, this.nativeLabel);

  final String code;
  final String label;
  final String nativeLabel;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? value) {
    for (final language in AppLanguage.values) {
      if (language.code == value) return language;
    }
    return AppLanguage.kyrgyz;
  }
}
