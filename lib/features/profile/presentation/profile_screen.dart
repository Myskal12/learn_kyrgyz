import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/progress_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final progress = context.watch<ProgressProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('???????')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.logged ? '??????????' : '?????', style: AppTextStyles.title),
                        Text(progress.level, style: AppTextStyles.muted),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/categories'),
                    icon: const Icon(Icons.explore),
                  )
                ],
              ),
              const SizedBox(height: 24),
              _ProfileStat(
                label: '???????? ??????',
                value: progress.totalWordsMastered.toString(),
                color: AppColors.accent,
              ),
              _ProfileStat(
                label: '?????????? ???????',
                value: progress.totalReviewSessions.toString(),
                color: AppColors.warning,
              ),
              _ProfileStat(
                label: '??????',
                value: '${progress.accuracyPercent}%',
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: auth.logged ? auth.logout : () => context.push('/login'),
                icon: Icon(auth.logged ? Icons.logout : Icons.login),
                label: Text(auth.logged ? '?????' : '?????'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => progress.reset(),
                icon: const Icon(Icons.refresh),
                label: const Text('?????????? ???????'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.title.copyWith(color: color)),
        ],
      ),
    );
  }
}
