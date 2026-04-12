import 'package:flutter/material.dart';

import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Колдонуу шарттары',
      subtitle: 'Колдонмонун негизги эрежелери',
      activeTab: AppTab.profile,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/settings',
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: const [
          _TermsIntro(
            title: 'Колдонуу шарттары',
            subtitle:
                'Это базовая внутренняя версия условий использования для текущего этапа разработки.',
          ),
          SizedBox(height: 12),
          _TermsSection(
            title: '1. Назначение приложения',
            body:
                'Приложение предназначено для изучения кыргызского языка, практики слов, предложений и базовой учебной аналитики.',
          ),
          SizedBox(height: 12),
          _TermsSection(
            title: '2. Аккаунт и доступ',
            body:
                'Пользователь может использовать приложение как гость или через аккаунт. Пользователь отвечает за корректность своих данных и безопасность своего входа.',
          ),
          SizedBox(height: 12),
          _TermsSection(
            title: '3. Ограничение ответственности',
            body:
                'Приложение предоставляется в текущем виде. На pre-release этапе отдельные функции, дизайн и структура данных могут меняться без отдельного уведомления.',
          ),
          SizedBox(height: 12),
          _TermsSection(
            title: '4. Контент и прогресс',
            body:
                'Учебный контент, уровни, streak, достижения и статистика являются частью сервиса и могут корректироваться по мере развития продукта.',
          ),
          SizedBox(height: 12),
          _TermsSection(
            title: '5. Недопустимое использование',
            body:
                'Запрещается использовать приложение для злоупотребления рейтингами, обхода ограничений, автоматизированного спама или вмешательства в нормальную работу сервиса.',
          ),
          SizedBox(height: 12),
          _TermsSection(
            title: '6. Статус документа',
            body:
                'Это skeleton-версия. Перед production-релизом документ должен быть заменён на полную юридическую редакцию.',
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TermsIntro extends StatelessWidget {
  const _TermsIntro({required this.title, required this.subtitle});

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

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.body});

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
