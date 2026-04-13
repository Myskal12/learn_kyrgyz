import 'package:flutter/widgets.dart';

import '../localization/app_copy.dart';

enum LearningDirection { kyToEn, enToKy }

extension LearningDirectionX on LearningDirection {
  static LearningDirection fromStorage(String? value) {
    switch (value) {
      case 'ky_to_en':
        return LearningDirection.kyToEn;
      case 'en_to_ky':
      default:
        return LearningDirection.enToKy;
    }
  }

  String get storageValue =>
      this == LearningDirection.kyToEn ? 'ky_to_en' : 'en_to_ky';

  String get shortLabel =>
      this == LearningDirection.kyToEn ? 'KG > EN' : 'EN > KG';

  String labelOf(BuildContext context) => this == LearningDirection.kyToEn
      ? context.tr(
          ky: 'Кыргызча -> Англисче',
          en: 'Kyrgyz -> English',
          ru: 'Кыргызский -> Английский',
        )
      : context.tr(
          ky: 'Англисче -> Кыргызча',
          en: 'English -> Kyrgyz',
          ru: 'Английский -> Кыргызский',
        );

  String promptLanguageLabelOf(BuildContext context) =>
      this == LearningDirection.kyToEn
      ? context.tr(ky: 'кыргызча', en: 'Kyrgyz', ru: 'кыргызском')
      : context.tr(ky: 'англисче', en: 'English', ru: 'английском');

  String answerLanguageLabelOf(BuildContext context) =>
      this == LearningDirection.kyToEn
      ? context.tr(ky: 'англисче', en: 'English', ru: 'английском')
      : context.tr(ky: 'кыргызча', en: 'Kyrgyz', ru: 'кыргызском');

  String helperTextOf(BuildContext context) => context.tr(
    ky: 'Суроо ${promptLanguageLabelOf(context)}, жооп ${answerLanguageLabelOf(context)}.',
    en: 'Prompt in ${promptLanguageLabelOf(context)}, answer in ${answerLanguageLabelOf(context)}.',
    ru: 'Вопрос на ${promptLanguageLabelOf(context)}, ответ на ${answerLanguageLabelOf(context)}.',
  );

  String semanticsLabelOf(BuildContext context) => context.tr(
    ky: 'Окуу багыты $shortLabel',
    en: 'Learning direction $shortLabel',
    ru: 'Направление обучения $shortLabel',
  );

  bool get isEnToKy => this == LearningDirection.enToKy;

  bool get isKyToEn => this == LearningDirection.kyToEn;
}
