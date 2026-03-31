import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/sticky_bottom_action_bar.dart';
import '../auth_demo_account.dart';
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

  void _fillDemoRegistration() {
    _name.text = AuthDemoAccount.name;
    _email.text = AuthDemoAccount.email;
    _password.text = AuthDemoAccount.password;
    _confirmPassword.text = AuthDemoAccount.password;
  }

  Future<void> _finishAuthFlow() async {
    await ref.read(onboardingProvider).completeOnboarding();
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _handleDemoAccess(AuthProvider auth) async {
    _setLocalError(null);
    _fillDemoRegistration();
    final ok = await auth.loginWithDemoAccount();
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
                              'Жаңы аккаунт',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Кыргызча жана англисче сүйлөшүүнү оңой үйрөнөсүз',
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
                              label: 'Толук аты',
                              icon: Icons.person_outline,
                              placeholder: AuthDemoAccount.name,
                            ),
                            const SizedBox(height: 16),
                            _AuthField(
                              controller: _email,
                              label: 'Электрондук почта',
                              icon: Icons.mail_outline,
                              placeholder: AuthDemoAccount.email,
                            ),
                            const SizedBox(height: 16),
                            _AuthField(
                              controller: _password,
                              label: 'Сыр сөз',
                              icon: Icons.lock_outline,
                              placeholder: AuthDemoAccount.password,
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
                              label: 'Сыр сөздү кайталаңыз',
                              icon: Icons.lock_reset,
                              placeholder: AuthDemoAccount.password,
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
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderColor: AppColors.primary.withValues(alpha: 0.18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Тест үчүн даяр профиль',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Бул блок тест аккаунтту дароо толтуруп, керек болсо өзү түзүп да киргизет.',
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 12),
                            const _CredentialLine(
                              label: 'Аты',
                              value: AuthDemoAccount.name,
                            ),
                            const SizedBox(height: 8),
                            const _CredentialLine(
                              label: 'Email',
                              value: AuthDemoAccount.email,
                            ),
                            const SizedBox(height: 8),
                            const _CredentialLine(
                              label: 'Сыр сөз',
                              value: AuthDemoAccount.password,
                            ),
                            const SizedBox(height: 14),
                            AdaptivePanelGrid(
                              maxColumns: 2,
                              minItemWidth: 150,
                              children: [
                                AppButton(
                                  size: AppButtonSize.sm,
                                  fullWidth: true,
                                  variant: AppButtonVariant.outlined,
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                          _fillDemoRegistration();
                                          _showMessage(
                                            'Тест аккаунт маалыматтары толтурулду.',
                                          );
                                        },
                                  child: const Text('Толтуруу'),
                                ),
                                AppButton(
                                  size: AppButtonSize.sm,
                                  fullWidth: true,
                                  onPressed: auth.isLoading
                                      ? null
                                      : () => _handleDemoAccess(auth),
                                  child: const Text('Түзүү же кирүү'),
                                ),
                              ],
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
                                _setLocalError('Толук атты жазыңыз.');
                                return;
                              }
                              if (_password.text != _confirmPassword.text) {
                                _setLocalError('Сыр сөздөр дал келбейт.');
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
                      child: Text(auth.isLoading ? '...' : 'Катталуу'),
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
                      child: const Text('Google менен катталуу'),
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
                        'Аккаунтуңуз барбы? Кирүү',
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

class _CredentialLine extends StatelessWidget {
  const _CredentialLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
