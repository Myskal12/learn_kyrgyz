import 'package:flutter/material.dart';

import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Купуялык саясаты',
      subtitle: 'Маалымат кантип колдонулат',
      activeTab: AppTab.profile,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/settings',
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: const [
          _LegalIntro(
            title: 'Купуялык саясаты',
            subtitle:
                'Это базовая внутренняя версия политики конфиденциальности для pre-release этапа.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: '1. Какие данные мы используем',
            body:
                'Приложение может хранить имя профиля, email аккаунта, прогресс обучения, streak, статистику ответов и локальные настройки интерфейса.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: '2. Где хранятся данные',
            body:
                'Часть данных хранится локально на устройстве. Если пользователь вошёл в аккаунт, часть данных также синхронизируется через Firebase Authentication и Cloud Firestore.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: '3. Для чего используются данные',
            body:
                'Данные используются для входа в аккаунт, восстановления прогресса, отображения профиля, лидерборда, достижений и персонализации учебного процесса.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: '4. Лидерборд и публичные элементы',
            body:
                'При использовании аккаунта отдельные агрегированные показатели, например имя профиля и учебная статистика, могут отображаться в лидерборде внутри приложения.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: '5. Управление данными',
            body:
                'Пользователь может выйти из аккаунта, очистить локальный прогресс и изменить часть профильных данных в настройках. Полное управление удалением аккаунта будет вынесено в отдельный flow позже.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: '6. Статус документа',
            body:
                'Это рабочий skeleton-документ. Перед публичным production-релизом его нужно заменить на финальную юридически проверенную версию.',
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LegalIntro extends StatelessWidget {
  const _LegalIntro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading.copyWith(fontSize: 28)),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTextStyles.muted),
      ],
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
