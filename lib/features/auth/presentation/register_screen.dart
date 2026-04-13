import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/sticky_bottom_action_bar.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  String? _localError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _setLocalError(String? value) {
    setState(() => _localError = value);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _finishAuthFlow() async {
    await ref
        .read(localStorageServiceProvider)
        .setString(Constants.postLogoutRedirectKey, 'false');
    await ref.read(onboardingProvider).completeOnboarding();
    if (!mounted) return;
    context.go('/auth-complete');
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
                              context.tr(
                                ky: 'Жаңы аккаунт',
                                en: 'Create account',
                                ru: 'Новый аккаунт',
                              ),
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr(
                                ky: 'Катталып, окууну улантыңыз.',
                                en: 'Sign up and continue learning.',
                                ru: 'Зарегистрируйтесь и продолжайте учиться.',
                              ),
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
                              controller: _name,
                              label: context.tr(
                                ky: 'Толук аты',
                                en: 'Full name',
                                ru: 'Полное имя',
                              ),
                              icon: Icons.person_outline,
                              placeholder: context.tr(
                                ky: 'Атыңыз',
                                en: 'Your name',
                                ru: 'Ваше имя',
                              ),
                            ),
                            const SizedBox(height: 16),
                            _AuthField(
                              controller: _email,
                              label: context.tr(
                                ky: 'Электрондук почта',
                                en: 'Email',
                                ru: 'Электронная почта',
                              ),
                              icon: Icons.mail_outline,
                              placeholder: 'name@example.com',
                            ),
                            const SizedBox(height: 16),
                            _AuthField(
                              controller: _password,
                              label: context.tr(
                                ky: 'Сыр сөз',
                                en: 'Password',
                                ru: 'Пароль',
                              ),
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
                            const SizedBox(height: 16),
                            _AuthField(
                              controller: _confirmPassword,
                              label: context.tr(
                                ky: 'Сыр сөздү кайталаңыз',
                                en: 'Confirm password',
                                ru: 'Повторите пароль',
                              ),
                              icon: Icons.lock_reset,
                              placeholder: '********',
                              obscureText: !_showConfirm,
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() => _showConfirm = !_showConfirm);
                                },
                                icon: Icon(
                                  _showConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.muted,
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
                    if (_localError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _localError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (auth.error != null && !auth.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          auth.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    AppButton(
                      key: const Key('register-primary-cta'),
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              final nickname = _name.text.trim();
                              final email = _email.text.trim();
                              if (nickname.isEmpty) {
                                _setLocalError(
                                  context.tr(
                                    ky: 'Толук атты жазыңыз.',
                                    en: 'Enter your full name.',
                                    ru: 'Введите полное имя.',
                                  ),
                                );
                                return;
                              }
                              if (_password.text != _confirmPassword.text) {
                                _setLocalError(
                                  context.tr(
                                    ky: 'Сыр сөздөр дал келбейт.',
                                    en: 'Passwords do not match.',
                                    ru: 'Пароли не совпадают.',
                                  ),
                                );
                                return;
                              }
                              _setLocalError(null);
                              final ok = await auth.register(
                                email,
                                _password.text,
                                nickname: nickname,
                              );
                              if (!context.mounted) return;
                              if (ok) {
                                await _finishAuthFlow();
                                return;
                              }
                              final error = auth.error;
                              if (error != null) {
                                _showMessage(error);
                              }
                            },
                      child: Text(
                        auth.isLoading
                            ? '...'
                            : context.tr(
                                ky: 'Катталуу',
                                en: 'Sign up',
                                ru: 'Регистрация',
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      variant: AppButtonVariant.outlined,
                      onPressed: auth.isLoading || !googleSupported
                          ? null
                          : () async {
                              _setLocalError(null);
                              final ok = await auth.loginWithGoogle();
                              if (!context.mounted) return;
                              if (ok) {
                                await _finishAuthFlow();
                                return;
                              }
                              final error = auth.error;
                              if (error != null) {
                                _showMessage(error);
                              }
                            },
                      child: Text(
                        context.tr(
                          ky: 'Google менен катталуу',
                          en: 'Sign up with Google',
                          ru: 'Регистрация через Google',
                        ),
                      ),
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
                      onPressed: () => context.push('/login'),
                      child: Text(
                        context.tr(
                          ky: 'Аккаунтуңуз барбы? Кирүү',
                          en: 'Already have an account? Sign in',
                          ru: 'Уже есть аккаунт? Войти',
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
