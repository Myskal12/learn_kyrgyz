import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/app_pattern_background.dart';

class LaunchGateScreen extends ConsumerStatefulWidget {
  const LaunchGateScreen({super.key});

  @override
  ConsumerState<LaunchGateScreen> createState() => _LaunchGateScreenState();
}

class _LaunchGateScreenState extends ConsumerState<LaunchGateScreen> {
  bool _redirectScheduled = false;

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);

    if (onboarding.isLoaded && !_redirectScheduled) {
      _redirectScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final storage = ref.read(localStorageServiceProvider);
        final firebase = ref.read(firebaseServiceProvider);
        final forceLogin =
            await storage.getString(Constants.postLogoutRedirectKey) == 'true';
        if (!mounted) return;

        final route = !onboarding.isCompleted
            ? '/welcome'
            : firebase.currentUserId != null
            ? firebase.isCurrentUserEmailVerificationRequired
                  ? '/verify-email'
                  : '/home'
            : forceLogin
            ? '/login'
            : '/home';
        this.context.go(route);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AppPatternBackground()),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
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
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Learn Kyrgyz', style: AppTextStyles.heading),
                  const SizedBox(height: 8),
                  Text(
                    'Күндүк практика үчүн колдонмону даярдап жатабыз.',
                    style: AppTextStyles.muted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
