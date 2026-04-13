import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key, this.backFallbackRoute = '/settings'});

  final String backFallbackRoute;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: context.tr(
        ky: 'Купуялык саясаты',
        en: 'Privacy policy',
        ru: 'Политика конфиденциальности',
      ),
      subtitle: context.tr(
        ky: 'Маалымат кантип колдонулат',
        en: 'How data is used',
        ru: 'Как используются данные',
      ),
      activeTab: AppTab.profile,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: backFallbackRoute,
      showBottomNav: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _LegalIntro(
            title: context.tr(
              ky: 'Купуялык саясаты',
              en: 'Privacy policy',
              ru: 'Политика конфиденциальности',
            ),
            subtitle: context.tr(
              ky: 'Бул pre-release баскычы үчүн саясаттын негизги ички версиясы.',
              en: 'This is a basic internal version of the privacy policy for the pre-release stage.',
              ru: 'Это базовая внутренняя версия политики конфиденциальности для pre-release этапа.',
            ),
          ),
          const SizedBox(height: 12),
          _LegalSection(
            title: context.tr(
              ky: '1. Кандай маалымат колдонулат',
              en: '1. What data we use',
              ru: '1. Какие данные мы используем',
            ),
            body: context.tr(
              ky: 'Колдонмо профиль атын, аккаунттагы email даректи, окуу прогрессин, серияны, жооп статистикасын жана локалдуу интерфейс жөндөөлөрүн сакташы мүмкүн.',
              en: 'The app may store your profile name, account email, learning progress, streak, answer statistics, and local interface settings.',
              ru: 'Приложение может хранить имя профиля, email аккаунта, прогресс обучения, streak, статистику ответов и локальные настройки интерфейса.',
            ),
          ),
          const SizedBox(height: 12),
          _LegalSection(
            title: context.tr(
              ky: '2. Маалымат кайда сакталат',
              en: '2. Where data is stored',
              ru: '2. Где хранятся данные',
            ),
            body: context.tr(
              ky: 'Маалыматтын бир бөлүгү түзмөктө локалдуу сакталат. Эгер колдонуучу аккаунтка кирсе, айрым маалыматтар Firebase Authentication жана Cloud Firestore аркылуу да синхрондолот.',
              en: 'Some data is stored locally on the device. If the user signs in, some data is also synced through Firebase Authentication and Cloud Firestore.',
              ru: 'Часть данных хранится локально на устройстве. Если пользователь вошёл в аккаунт, часть данных также синхронизируется через Firebase Authentication и Cloud Firestore.',
            ),
          ),
          const SizedBox(height: 12),
          _LegalSection(
            title: context.tr(
              ky: '3. Маалымат эмне үчүн колдонулат',
              en: '3. What data is used for',
              ru: '3. Для чего используются данные',
            ),
            body: context.tr(
              ky: 'Маалымат аккаунтка кирүү, прогрессти калыбына келтирүү, профиль, лидерборд, жетишкендиктер жана окуу процессин жекелештирүү үчүн колдонулат.',
              en: 'Data is used for account access, progress recovery, profile display, leaderboard, achievements, and personalization of learning.',
              ru: 'Данные используются для входа в аккаунт, восстановления прогресса, отображения профиля, лидерборда, достижений и персонализации учебного процесса.',
            ),
          ),
          const SizedBox(height: 12),
          _LegalSection(
            title: context.tr(
              ky: '4. Лидерборд жана ачык элементтер',
              en: '4. Leaderboard and public elements',
              ru: '4. Лидерборд и публичные элементы',
            ),
            body: context.tr(
              ky: 'Аккаунт колдонулганда, айрым жыйналган көрсөткүчтөр, мисалы профиль аты жана окуу статистикасы, колдонмонун ичиндеги лидерборддо көрүнүшү мүмкүн.',
              en: 'When using an account, some aggregated indicators, such as profile name and learning stats, may appear in the in-app leaderboard.',
              ru: 'При использовании аккаунта отдельные агрегированные показатели, например имя профиля и учебная статистика, могут отображаться в лидерборде внутри приложения.',
            ),
          ),
          const SizedBox(height: 12),
          _LegalSection(
            title: context.tr(
              ky: '5. Маалыматты башкаруу',
              en: '5. Data management',
              ru: '5. Управление данными',
            ),
            body: context.tr(
              ky: 'Колдонуучу аккаунттан чыгып, локалдуу прогрессти тазалап жана жөндөөлөрдө айрым профиль маалыматтарын өзгөртө алат. Аккаунтту толук өчүрүү кийин өзүнчө flow болуп чыгат.',
              en: 'The user can sign out, clear local progress, and change some profile data in settings. Full account deletion will be moved to a separate flow later.',
              ru: 'Пользователь может выйти из аккаунта, очистить локальный прогресс и изменить часть профильных данных в настройках. Полное управление удалением аккаунта будет вынесено в отдельный flow позже.',
            ),
          ),
          const SizedBox(height: 12),
          _LegalSection(
            title: context.tr(
              ky: '6. Документтин абалы',
              en: '6. Document status',
              ru: '6. Статус документа',
            ),
            body: context.tr(
              ky: 'Бул иштеп жаткан skeleton-документ. Коомдук production-релиздин алдында аны юридикалык жактан текшерилген финалдык версияга алмаштыруу керек.',
              en: 'This is a working skeleton document. Before a public production release, it should be replaced with a final legally reviewed version.',
              ru: 'Это рабочий skeleton-документ. Перед публичным production-релизом его нужно заменить на финальную юридически проверенную версию.',
            ),
          ),
          const SizedBox(height: 24),
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
