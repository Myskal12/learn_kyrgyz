enum LearningDirection { enToKy, kyToEn }

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

  String get label =>
      this == LearningDirection.kyToEn ? 'KY -> EN' : 'EN -> KY';

  bool get isEnToKy => this == LearningDirection.enToKy;
}
