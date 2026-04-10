class LearningResourceModel {
  const LearningResourceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.order,
    this.active = true,
  });

  static const fallback = <LearningResourceModel>[
    LearningResourceModel(
      id: 'glosbe_dictionary',
      title: 'Онлайн сөздүк',
      description:
          'Glosbe аркылуу англисче-кыргызча жана кыргызча-англисче издеңиз.',
      url: 'https://en.glosbe.com/en/ky',
      order: 10,
    ),
    LearningResourceModel(
      id: 'audio_tales',
      title: 'Аудио практика',
      description:
          'Кыргызча аудио жомокторду вебден угуп, угуу көндүмүн бекемдеңиз.',
      url:
          'https://podcasts.apple.com/us/podcast/%D0%BA%D1%8B%D1%80%D0%B3%D1%8B%D0%B7%D1%87%D0%B0-%D0%B0%D1%83%D0%B4%D0%B8%D0%BE-%D0%B6%D0%BE%D0%BC%D0%BE%D0%BA%D1%82%D0%BE%D1%80/id1526021082',
      order: 20,
    ),
    LearningResourceModel(
      id: 'video_lessons',
      title: 'Видео сабактар',
      description: '50languages сайтындагы башталгыч видео сабактар.',
      url: 'https://www.50languages.com/em/videos/ky',
      order: 30,
    ),
  ];

  final String id;
  final String title;
  final String description;
  final String url;
  final int order;
  final bool active;

  factory LearningResourceModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    final title = json['title']?.toString().trim();
    final description = json['description']?.toString().trim();
    final url = json['url']?.toString().trim();

    if (id == null || id.isEmpty) {
      throw const FormatException('Resource id is required');
    }
    if (title == null || title.isEmpty) {
      throw const FormatException('Resource title is required');
    }
    if (description == null || description.isEmpty) {
      throw const FormatException('Resource description is required');
    }
    if (url == null || url.isEmpty) {
      throw const FormatException('Resource url is required');
    }

    return LearningResourceModel(
      id: id,
      title: title,
      description: description,
      url: url,
      order: (json['order'] as num?)?.toInt() ?? 1000,
      active: (json['active'] as bool?) ?? true,
    );
  }
}
