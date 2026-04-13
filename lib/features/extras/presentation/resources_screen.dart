import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/learning_resource_model.dart';
import '../../../shared/widgets/app_shell.dart';
import '../providers/content_config_provider.dart';

class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key, this.backFallbackRoute = '/profile'});

  final String backFallbackRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(learningResourcesProvider);
    final resources =
        resourcesAsync.valueOrNull ?? LearningResourceModel.fallback;

    return AppShell(
      title: context.tr(ky: 'Ресурстар', en: 'Resources', ru: 'Ресурсы'),
      subtitle: context.tr(
        ky: 'Тышкы материалдар жана кошумча практика',
        en: 'External materials and extra practice',
        ru: 'Внешние материалы и дополнительная практика',
      ),
      activeTab: AppTab.profile,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: backFallbackRoute,
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
                  SnackBar(
                    content: Text(
                      context.tr(
                        ky: 'Шилтемени ачуу мүмкүн болгон жок.',
                        en: 'Could not open the link.',
                        ru: 'Не удалось открыть ссылку.',
                      ),
                    ),
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
