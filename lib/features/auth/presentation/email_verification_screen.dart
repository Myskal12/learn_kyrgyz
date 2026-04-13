import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/sticky_bottom_action_bar.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key, this.returnTo});

  final String? returnTo;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen>
    with WidgetsBindingObserver {
  bool _redirectScheduled = false;
  bool _refreshInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshVerification(silent: true);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _signedInReturnRoute => widget.returnTo ?? '/auth-complete';

  Future<void> _refreshVerification({bool silent = false}) async {
    if (_refreshInFlight) return;
    final auth = ref.read(authProvider);
    if (!auth.logged) {
      if (!mounted) return;
      context.go('/login');
      return;
    }
    if (!auth.requiresEmailVerification) {
      if (!mounted) return;
      context.go(_signedInReturnRoute);
      return;
    }

    _refreshInFlight = true;
    final verified = await auth.refreshEmailVerificationStatus();
    _refreshInFlight = false;

    if (!mounted) return;
    if (verified) {
      context.go(_signedInReturnRoute);
      return;
    }
    if (!silent) {
      _showMessage(
        auth.error ??
            context.tr(
              ky: 'Email дареги али ырастала элек.',
              en: 'The email address is not verified yet.',
              ru: 'Email адрес ещё не подтверждён.',
            ),
      );
    }
  }

  Future<void> _resendVerification() async {
    final auth = ref.read(authProvider);
    final ok = await auth.sendEmailVerification();
    if (!mounted) return;
    if (ok) {
      _showMessage(
        context.tr(
          ky: 'Ырастоо каты кайра жөнөтүлдү.',
          en: 'Verification email was sent again.',
          ru: 'Письмо для подтверждения отправлено повторно.',
        ),
      );
      return;
    }
    final error = auth.error;
    if (error != null) {
      _showMessage(error);
    }
  }

  Future<void> _logout() async {
    await ref
        .read(localStorageServiceProvider)
        .setString(Constants.postLogoutRedirectKey, 'true');
    await ref.read(authProvider).logout();
    if (!mounted) return;
    context.go('/login');
  }

  void _skipForNow() {
    context.go(_signedInReturnRoute);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final email = auth.currentUserEmail?.trim();

    if (!_redirectScheduled &&
        (!auth.logged || !auth.requiresEmailVerification)) {
      _redirectScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(auth.logged ? _signedInReturnRoute : '/login');
      });
    }

    return AppShell(
      title: '',
      showTopNav: false,
      showBottomNav: false,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: auth.logged ? _signedInReturnRoute : '/login',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.mark_email_read_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.tr(
                                ky: 'Email даректи ырастаңыз',
                                en: 'Verify your email',
                                ru: 'Подтвердите email',
                              ),
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              email == null || email.isEmpty
                                  ? context.tr(
                                      ky: 'Firebase ырастоо каты жөнөтүлдү. Почтаңызды ачып, шилтемени басыңыз.',
                                      en: 'A Firebase verification email was sent. Open your inbox and tap the link.',
                                      ru: 'Письмо подтверждения Firebase отправлено. Откройте почту и нажмите ссылку.',
                                    )
                                  : context.tr(
                                      ky: '$email дарегине кат жөнөтүлдү. Шилтемени ачып, кайра бул жерге келиңиз.',
                                      en: 'An email was sent to $email. Open the link and return here.',
                                      ru: 'Письмо отправлено на $email. Откройте ссылку и вернитесь сюда.',
                                    ),
                              style: AppTextStyles.muted,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.tr(
                                ky: 'Бул кадамды кийин да бүтүрсөңүз болот.',
                                en: 'You can also finish this step later.',
                                ru: 'Этот шаг можно завершить и позже.',
                              ),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.link,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(
                                ky: 'Эмне кылуу керек?',
                                en: 'What should you do?',
                                ru: 'Что нужно сделать?',
                              ),
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr(
                                ky: '1. Почтаңыздагы катты ачыңыз.',
                                en: '1. Open the email in your inbox.',
                                ru: '1. Откройте письмо в почте.',
                              ),
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr(
                                ky: '2. Ырастоо шилтемесин басыңыз.',
                                en: '2. Tap the verification link.',
                                ru: '2. Нажмите ссылку подтверждения.',
                              ),
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr(
                                ky: '3. Колдонмого кайтып келип текшерүү баскычын басыңыз.',
                                en: '3. Return to the app and tap the check button.',
                                ru: '3. Вернитесь в приложение и нажмите кнопку проверки.',
                              ),
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr(
                                ky: 'Кат көрүнбөсө, Spam же Promotions папкасын текшериңиз.',
                                en: 'If you cannot see the email, check Spam or Promotions.',
                                ru: 'Если письма не видно, проверьте папки Spam или Promotions.',
                              ),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.link,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StickyBottomActionBar(
                maxWidth: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (auth.error != null && !auth.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          auth.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      onPressed: auth.isLoading
                          ? null
                          : () => _refreshVerification(),
                      child: Text(
                        auth.isLoading
                            ? context.tr(
                                ky: 'Текшерилип жатат...',
                                en: 'Checking...',
                                ru: 'Проверяем...',
                              )
                            : context.tr(
                                ky: 'Мен ырастап койдум',
                                en: 'I have verified it',
                                ru: 'Я уже подтвердил',
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      variant: AppButtonVariant.outlined,
                      onPressed: auth.isLoading ? null : _resendVerification,
                      child: Text(
                        context.tr(
                          ky: 'Катты кайра жөнөтүү',
                          en: 'Resend email',
                          ru: 'Отправить письмо снова',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      variant: AppButtonVariant.outlined,
                      onPressed: auth.isLoading ? null : _skipForNow,
                      child: Text(
                        context.tr(ky: 'Кийинчерээк', en: 'Later', ru: 'Позже'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: auth.isLoading ? null : _logout,
                      child: Text(
                        context.tr(
                          ky: 'Башка аккаунт менен кирүү',
                          en: 'Sign in with another account',
                          ru: 'Войти с другим аккаунтом',
                        ),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.link,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
