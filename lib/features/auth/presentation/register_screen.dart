import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

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
                        'Жаңы аккаунт',
                        style: AppTextStyles.heading.copyWith(fontSize: 28),
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
                        placeholder: 'Айгүл Асанова',
                      ),
                      const SizedBox(height: 16),
                      _AuthField(
                        controller: _email,
                        label: 'Электрондук почта',
                        icon: Icons.mail_outline,
                        placeholder: 'example@email.com',
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
                      const SizedBox(height: 16),
                      _AuthField(
                        controller: _confirmPassword,
                        label: 'Сыр сөздү кайталаңыз',
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
                const SizedBox(height: 16),
                if (_localError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _localError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (auth.error != null && !auth.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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
                            context.go('/');
                            return;
                          }
                          final error = auth.error;
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error)),
                            );
                          }
                        },
                  child: Text(auth.isLoading ? '...' : 'Катталуу'),
                ),
                const SizedBox(height: 12),
                AppButton(
                  fullWidth: true,
                  size: AppButtonSize.lg,
                  variant: AppButtonVariant.outlined,
                  onPressed: auth.isLoading ? null : () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.account_circle_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Google менен катталуу'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Аккаунтуңуз барбы?',
                  style: AppTextStyles.muted,
                ),
                TextButton(
                  onPressed: () => context.push('/login'),
                  child: Text(
                    'Кирүү',
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
