import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key, this.backFallbackRoute = '/settings'});

  final String backFallbackRoute;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: context.tr(
        ky: 'Колдонуу шарттары',
        en: 'Terms of use',
        ru: 'Условия использования',
      ),
      subtitle: context.tr(
        ky: 'Колдонмонун негизги эрежелери',
        en: 'Core rules of the app',
        ru: 'Основные правила приложения',
      ),
      activeTab: AppTab.profile,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: backFallbackRoute,
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _TermsIntro(
            title: context.tr(
              ky: 'Колдонуу шарттары',
              en: 'Terms of use',
              ru: 'Условия использования',
            ),
            subtitle: context.tr(
              ky: 'Бул өнүгүүнүн учурдагы баскычы үчүн колдонуу шарттарынын ички базалык версиясы.',
              en: 'This is a basic internal version of the terms of use for the current development stage.',
              ru: 'Это базовая внутренняя версия условий использования для текущего этапа разработки.',
            ),
          ),
          const SizedBox(height: 12),
          _TermsSection(
            title: context.tr(
              ky: '1. Колдонмонун максаты',
              en: '1. Purpose of the app',
              ru: '1. Назначение приложения',
            ),
            body: context.tr(
              ky: 'Колдонмо кыргыз тилин үйрөнүү, сөздөрдү жана сүйлөмдөрдү практикалоо жана негизги окуу аналитикасы үчүн арналган.',
              en: 'The app is intended for learning Kyrgyz, practicing words and sentences, and basic learning analytics.',
              ru: 'Приложение предназначено для изучения кыргызского языка, практики слов, предложений и базовой учебной аналитики.',
            ),
          ),
          const SizedBox(height: 12),
          _TermsSection(
            title: context.tr(
              ky: '2. Аккаунт жана жеткиликтүүлүк',
              en: '2. Account and access',
              ru: '2. Аккаунт и доступ',
            ),
            body: context.tr(
              ky: 'Колдонуучу колдонмону конок катары же аккаунт аркылуу пайдалана алат. Колдонуучу өз маалыматынын тууралыгы жана кирүүсүнүн коопсуздугу үчүн жооп берет.',
              en: 'The user may use the app as a guest or through an account. The user is responsible for the correctness of their data and the security of their access.',
              ru: 'Пользователь может использовать приложение как гость или через аккаунт. Пользователь отвечает за корректность своих данных и безопасность своего входа.',
            ),
          ),
          const SizedBox(height: 12),
          _TermsSection(
            title: context.tr(
              ky: '3. Жоопкерчиликти чектөө',
              en: '3. Limitation of liability',
              ru: '3. Ограничение ответственности',
            ),
            body: context.tr(
              ky: 'Колдонмо учурдагы түрүндө берилет. Pre-release баскычында айрым функциялар, дизайн жана маалымат түзүмү өзүнчө эскертүүсүз өзгөрүшү мүмкүн.',
              en: 'The app is provided as is. During the pre-release stage, some features, design, and data structure may change without separate notice.',
              ru: 'Приложение предоставляется в текущем виде. На pre-release этапе отдельные функции, дизайн и структура данных могут меняться без отдельного уведомления.',
            ),
          ),
          const SizedBox(height: 12),
          _TermsSection(
            title: context.tr(
              ky: '4. Контент жана прогресс',
              en: '4. Content and progress',
              ru: '4. Контент и прогресс',
            ),
            body: context.tr(
              ky: 'Окуу контенти, деңгээлдер, серия, жетишкендиктер жана статистика сервисинин бөлүгү болуп саналат жана продукт өнүккөн сайын өзгөрүшү мүмкүн.',
              en: 'Learning content, levels, streak, achievements, and statistics are part of the service and may be adjusted as the product evolves.',
              ru: 'Учебный контент, уровни, streak, достижения и статистика являются частью сервиса и могут корректироваться по мере развития продукта.',
            ),
          ),
          const SizedBox(height: 12),
          _TermsSection(
            title: context.tr(
              ky: '5. Жол берилбеген колдонуу',
              en: '5. Prohibited use',
              ru: '5. Недопустимое использование',
            ),
            body: context.tr(
              ky: 'Колдонмону рейтингди бурмалоо, чектөөлөрдү айланып өтүү, автоматтык спам же сервистин кадимки ишине кийлигишүү үчүн колдонууга болбойт.',
              en: 'It is prohibited to use the app for leaderboard abuse, bypassing limits, automated spam, or interference with normal service operation.',
              ru: 'Запрещается использовать приложение для злоупотребления рейтингами, обхода ограничений, автоматизированного спама или вмешательства в нормальную работу сервиса.',
            ),
          ),
          const SizedBox(height: 12),
          _TermsSection(
            title: context.tr(
              ky: '6. Документтин абалы',
              en: '6. Document status',
              ru: '6. Статус документа',
            ),
            body: context.tr(
              ky: 'Бул skeleton-версия. Production-релиздин алдында документ толук юридикалык редакцияга алмаштырылышы керек.',
              en: 'This is a skeleton version. Before production release, the document must be replaced with a full legal edition.',
              ru: 'Это skeleton-версия. Перед production-релизом документ должен быть заменён на полную юридическую редакцию.',
            ),
          ),
          const SizedBox(height: 24),
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
