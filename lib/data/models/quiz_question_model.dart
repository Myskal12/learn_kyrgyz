class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.question,
    required this.correct,
    required this.options,
    required this.category,
    required this.level,
    this.wordId,
  });

  final String id;
  final String question;
  final String correct;
  final List<String> options;
  final String category;
  final int level;
  final String? wordId;

  factory QuizQuestionModel.fromJson(String id, Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>? ?? <dynamic>[])
        .map((value) => value.toString())
        .toList();
    return QuizQuestionModel(
      id: id,
      question: json['question'] as String? ?? '',
      correct: json['correct'] as String? ?? '',
      options: rawOptions,
      category: json['category'] as String? ?? 'basic',
      level: (json['level'] as num?)?.toInt() ?? 1,
      wordId: json['wordId'] as String? ?? json['word_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'correct': correct,
    'options': options,
    'category': category,
    'level': level,
    if (wordId != null) 'wordId': wordId,
  };
}
