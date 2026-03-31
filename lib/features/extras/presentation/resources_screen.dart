import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_shell.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = [
      _ResourceCard(
        title: 'Онлайн сөздүк',
        description:
            'Glosbe аркылуу англисче-кыргызча жана кыргызча-англисче издеңиз.',
        url: 'https://en.glosbe.com/en/ky',
      ),
      _ResourceCard(
        title: 'Аудио практика',
        description:
            'Кыргызча аудио жомокторду вебден угуп, угуу көндүмүн бекемдеңиз.',
        url:
            'https://podcasts.apple.com/us/podcast/%D0%BA%D1%8B%D1%80%D0%B3%D1%8B%D0%B7%D1%87%D0%B0-%D0%B0%D1%83%D0%B4%D0%B8%D0%BE-%D0%B6%D0%BE%D0%BC%D0%BE%D0%BA%D1%82%D0%BE%D1%80/id1526021082',
      ),
      _ResourceCard(
        title: 'Видео сабактар',
        description: '50languages сайтындагы башталгыч видео сабактар.',
        url: 'https://www.50languages.com/em/videos/ky',
      ),
    ];

    return AppShell(
      title: 'Ресурстар',
      subtitle: 'Тышкы материалдар жана кошумча практика',
      activeTab: AppTab.profile,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/profile',
      showBottomNav: false,
      child: ListView.builder(
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
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final uri = Uri.parse(item.url);
                final ok = await launchUrl(uri, webOnlyWindowName: '_blank');
                if (!context.mounted || ok) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Шилтемени ачуу мүмкүн болгон жок.'),
                  ),
                );
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
