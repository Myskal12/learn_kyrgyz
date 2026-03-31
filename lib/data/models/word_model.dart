class WordModel {
  final String id;
  final String english;
  final String kyrgyz;
  final String transcription;
  final String example;
  final int level;
  final String category;
  final String transcriptionKy;

  const WordModel({
    required this.id,
    required this.english,
    required this.kyrgyz,
    this.transcription = '',
    this.example = '',
    this.level = 1,
    this.category = '',
    this.transcriptionKy = '',
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    final english = (json['english'] ?? json['en'] ?? json['question'] ?? '')
        .toString();
    final kyrgyz = (json['kyrgyz'] ?? json['ky'] ?? json['correct'] ?? '')
        .toString();
    final transcription =
        (json['transcription'] ?? json['transcription_en'] ?? '').toString();
    final transcriptionKy =
        (json['transcriptionKy'] ??
                json['transcription_ky'] ??
                json['transcription_kg'] ??
                '')
            .toString();
    final example =
        (json['example'] ?? json['example_ky'] ?? json['exampleKy'] ?? '')
            .toString();

    return WordModel(
      id: (json['id'] ?? json['wordId'] ?? json['word_id'] ?? '').toString(),
      english: english,
      kyrgyz: kyrgyz,
      transcription: transcription,
      transcriptionKy: transcriptionKy,
      example: example,
      level: (json['level'] as num?)?.toInt() ?? 1,
      category: (json['category'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'english': english,
    'kyrgyz': kyrgyz,
    'transcription': transcription,
    'transcriptionKy': transcriptionKy,
    'example': example,
    'level': level,
    'category': category,
  };
}
