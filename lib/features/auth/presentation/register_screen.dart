import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_text_styles.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nickname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _nickname.dispose();
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
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Катталуу')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Жаңы аккаунт түзүңүз', style: AppTextStyles.heading),
              const SizedBox(height: 6),
              Text(
                'Email, никнейм жана сырсөздү толтуруп, сырсөздү эки жолу жазыңыз.',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 24),
              _RegisterField(
                controller: _nickname,
                label: 'Никнейм',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              _RegisterField(
                controller: _email,
                label: 'Email',
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 14),
              _RegisterField(
                controller: _password,
                label: 'Сырсөз',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              _RegisterField(
                controller: _confirmPassword,
                label: 'Сырсөздү кайталаңыз',
                icon: Icons.lock_reset,
                obscureText: true,
              ),
              const SizedBox(height: 18),
              if (_localError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _localError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (auth.error != null && !isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final nickname = _nickname.text.trim();
                          final email = _email.text.trim();
                          if (nickname.isEmpty) {
                            _setLocalError('Никнеймди жазыңыз.');
                            return;
                          }
                          if (_password.text != _confirmPassword.text) {
                            _setLocalError('Сырсөздөр дал келбей жатат.');
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
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(isLoading ? '...' : 'Катталуу'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
