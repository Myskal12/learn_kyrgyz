import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_text_styles.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Кирүү')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Кош келдиңиз!', style: AppTextStyles.heading),
                      const SizedBox(height: 6),
                      Text(
                        'Аккаунтуңузга кирип прогрессти синхрондоштуруңуз же Google менен улантыңыз.',
                        style: AppTextStyles.muted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _AuthField(
                controller: _email,
                label: 'Email',
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 16),
              _AuthField(
                controller: _password,
                label: 'Сырсөз',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (auth.error != null && !auth.isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              _PrimaryAction(
                enabled: !auth.isLoading,
                label: 'Кирүү',
                onPressed: () async {
                  final ok = await auth.login(
                    _email.text.trim(),
                    _password.text,
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
              ),
              const SizedBox(height: 12),
              _PrimaryAction(
                enabled: !auth.isLoading,
                outlined: true,
                icon: Icons.account_circle_outlined,
                label: 'Google менен кирүү',
                onPressed: () async {
                  final ok = await auth.loginWithGoogle();
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
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Катталуу'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.enabled,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );

    final button = outlined
        ? OutlinedButton(onPressed: enabled ? onPressed : null, child: child)
        : FilledButton(onPressed: enabled ? onPressed : null, child: child);

    return SizedBox(width: double.infinity, child: button);
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
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
