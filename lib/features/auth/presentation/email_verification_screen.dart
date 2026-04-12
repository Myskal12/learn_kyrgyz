import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
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
      _showMessage(auth.error ?? 'Email дареги али ырастала элек.');
    }
  }

  Future<void> _resendVerification() async {
    final auth = ref.read(authProvider);
    final ok = await auth.sendEmailVerification();
    if (!mounted) return;
    if (ok) {
      _showMessage('Ырастоо каты кайра жөнөтүлдү.');
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
                              'Email даректи ырастаңыз',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              email == null || email.isEmpty
                                  ? 'Firebase ырастоо каты жөнөтүлдү. Почтаңызды ачып, шилтемени басыңыз.'
                                  : '$email дарегине кат жөнөтүлдү. Шилтемени ачып, кайра бул жерге келиңиз.',
                              style: AppTextStyles.muted,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Бул кадамды кийин да бүтүрсөңүз болот.',
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
                              'Эмне кылуу керек?',
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '1. Почтаңыздагы катты ачыңыз.',
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '2. Ырастоо шилтемесин басыңыз.',
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '3. Колдонмого кайтып келип текшерүү баскычын басыңыз.',
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Кат көрүнбөсө, Spam же Promotions папкасын текшериңиз.',
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
                            ? 'Текшерилип жатат...'
                            : 'Мен ырастап койдум',
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      variant: AppButtonVariant.outlined,
                      onPressed: auth.isLoading ? null : _resendVerification,
                      child: const Text('Катты кайра жөнөтүү'),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      variant: AppButtonVariant.outlined,
                      onPressed: auth.isLoading ? null : _skipForNow,
                      child: const Text('Кийинчерээк'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: auth.isLoading ? null : _logout,
                      child: Text(
                        'Башка аккаунт менен кирүү',
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
