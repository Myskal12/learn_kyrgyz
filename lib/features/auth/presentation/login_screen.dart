import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/sticky_bottom_action_bar.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handlePasswordReset(AuthProvider auth) async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _showMessage('Адегенде email дарегиңизди жазыңыз.');
      return;
    }

    final ok = await auth.sendPasswordResetEmail(email);
    if (!mounted) return;
    if (ok) {
      _showMessage('Сыр сөздү жаңыртуу шилтемеси email дарегине жөнөтүлдү.');
      return;
    }
    final error = auth.error;
    if (error != null) {
      _showMessage(error);
    }
  }

  Future<void> _finishAuthFlow() async {
    await ref.read(localStorageServiceProvider).setString(
      Constants.postLogoutRedirectKey,
      'false',
    );
    await ref.read(onboardingProvider).completeOnboarding();
    if (!mounted) return;
    context.go('/auth-complete');
  }

  Future<void> _handleEmailLogin(AuthProvider auth) async {
    final ok = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      await _finishAuthFlow();
      return;
    }
    final error = auth.error;
    if (error != null) {
      _showMessage(error);
    }
  }

  Future<void> _handleGoogleLogin(AuthProvider auth) async {
    final ok = await auth.loginWithGoogle();
    if (!mounted) return;
    if (ok) {
      await _finishAuthFlow();
      return;
    }
    final error = auth.error;
    if (error != null) {
      _showMessage(error);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final googleSupported = auth.isGoogleSignInSupported;

    return AppShell(
      title: '',
      showTopNav: false,
      showBottomNav: false,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/welcome',
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
                              child: const Text(
                                'КЕ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Кош келиңиз!',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Улантуу үчүн кириңиз.',
                              style: AppTextStyles.muted,
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
                            _AuthField(
                              controller: _email,
                              label: 'Электрондук почта',
                              icon: Icons.mail_outline,
                              placeholder: 'name@example.com',
                            ),
                            const SizedBox(height: 16),
                            _AuthField(
                              controller: _password,
                              label: 'Сыр сөз',
                              icon: Icons.lock_outline,
                              placeholder: '********',
                              obscureText: !_showPassword,
                              suffix: IconButton(
                                onPressed: () {
                                  setState(
                                    () => _showPassword = !_showPassword,
                                  );
                                },
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () => _handlePasswordReset(auth),
                                child: Text(
                                  'Сыр сөздү унуттуңузбу?',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.link,
                                    fontSize: 13,
                                  ),
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
                      key: const Key('login-primary-cta'),
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      onPressed: auth.isLoading
                          ? null
                          : () => _handleEmailLogin(auth),
                      child: const Text('Кирүү'),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      variant: AppButtonVariant.outlined,
                      onPressed: auth.isLoading || !googleSupported
                          ? null
                          : () => _handleGoogleLogin(auth),
                      child: const Text('Google менен кирүү'),
                    ),
                    if (!googleSupported)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          auth.googleSignInUnavailableMessage,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.muted.copyWith(fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: Text(
                        'Аккаунтуңуз жокпу? Катталуу',
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

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.placeholder,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String placeholder;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: Icon(icon, color: AppColors.muted),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
