import 'package:flutter/material.dart';

import '../../../core/utils/app_text_styles.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = [
      _ResourceCard(
        title: 'Онлайн сөздүк',
        description: 'Киргизче-англисче сөздөрдү табуу үчүн ишенимдүү ресурс.',
        url: 'https://sozdik.example',
      ),
      _ResourceCard(
        title: 'Подкасттар',
        description:
            'Кулакка жагымдуу аудио эпизоддор менен угуу көндүмүн бекемдеңиз.',
        url: 'https://music.example',
      ),
      _ResourceCard(
        title: 'Видео сабактар',
        description: 'YouTube плейлисти: темага жараша кыска видеолор.',
        url: 'https://video.example',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ресурстар')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final item = resources[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(item.title, style: AppTextStyles.title),
              subtitle: Text(item.description),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('URL: ${item.url}')));
              },
            ),
          );
        },
      ),
    );
  }
}

class _ResourceCard {
  const _ResourceCard({
    required this.title,
    required this.description,
    required this.url,
  });
  final String title;
  final String description;
  final String url;
}
