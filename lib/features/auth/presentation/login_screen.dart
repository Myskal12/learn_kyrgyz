import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../auth_demo_account.dart';
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

  void _fillDemoCredentials() {
    _email.text = AuthDemoAccount.email;
    _password.text = AuthDemoAccount.password;
  }

  Future<void> _finishAuthFlow() async {
    await ref.read(onboardingProvider).completeOnboarding();
    if (!mounted) return;
    context.go('/home');
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

  Future<void> _handleDemoLogin(AuthProvider auth) async {
    _fillDemoCredentials();
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
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
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
                        style: AppTextStyles.heading.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Кыргызча жана англисче сүйлөөнү чогуу үйрөнөбүз',
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
                            setState(() => _showPassword = !_showPassword);
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
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(18),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  borderColor: AppColors.primary.withValues(alpha: 0.18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Тест аккаунт',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Демо профилди бир таптоо менен ачып, auth flow\'ду тез текшерсеңиз болот.',
                        style: AppTextStyles.muted,
                      ),
                      const SizedBox(height: 12),
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
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              size: AppButtonSize.sm,
                              variant: AppButtonVariant.outlined,
                              onPressed: auth.isLoading
                                  ? null
                                  : () {
                                      _fillDemoCredentials();
                                      _showMessage(
                                        'Тест аккаунт маалыматтары талааларга коюлду.',
                                      );
                                    },
                              child: const Text('Толтуруу'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              size: AppButtonSize.sm,
                              onPressed: auth.isLoading
                                  ? null
                                  : () => _handleDemoLogin(auth),
                              child: const Text('Тез кирүү'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (auth.error != null && !auth.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      auth.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                AppButton(
                  fullWidth: true,
                  size: AppButtonSize.lg,
                  onPressed: auth.isLoading
                      ? null
                      : () => _handleEmailLogin(auth),
                  child: const Text('Кирүү'),
                ),
                const SizedBox(height: 12),
                AppButton(
                  fullWidth: true,
                  size: AppButtonSize.lg,
                  variant: AppButtonVariant.outlined,
                  onPressed: auth.isLoading || !googleSupported
                      ? null
                      : () => _handleGoogleLogin(auth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.account_circle_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Google менен кирүү'),
                    ],
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
                const SizedBox(height: 16),
                Text('Аккаунтуңуз жокпу?', style: AppTextStyles.muted),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: Text(
                    'Катталуу',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.link,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
