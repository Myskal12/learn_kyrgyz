class SentenceModel {
  const SentenceModel({
    required this.id,
    required this.en,
    required this.ky,
    this.highlight = '',
    this.wordEn = '',
    this.wordKy = '',
    this.wordId,
    this.level = 1,
    this.category = '',
  });

  final String id;
  final String en;
  final String ky;
  final String highlight;
  final String wordEn;
  final String wordKy;
  final String? wordId;
  final int level;
  final String category;

  factory SentenceModel.fromJson(String id, Map<String, dynamic> json) {
    return SentenceModel(
      id: id,
      en: (json['en'] ?? json['english'] ?? '').toString(),
      ky: (json['ky'] ?? json['kyrgyz'] ?? '').toString(),
      highlight: (json['highlight'] ?? '').toString(),
      wordEn: (json['word_en'] ?? json['wordEn'] ?? '').toString(),
      wordKy: (json['word_ky'] ?? json['wordKy'] ?? '').toString(),
      wordId: (json['wordId'] ?? json['word_id'])?.toString(),
      level: (json['level'] as num?)?.toInt() ?? 1,
      category: (json['category'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'en': en,
    'ky': ky,
    'highlight': highlight,
    'word_en': wordEn,
    'word_ky': wordKy,
    if (wordId != null) 'wordId': wordId,
    'level': level,
    'category': category,
  };
}
