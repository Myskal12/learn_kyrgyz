import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_pattern_background.dart';
import '../../profile/providers/user_profile_provider.dart';

class AuthCompleteScreen extends ConsumerStatefulWidget {
  const AuthCompleteScreen({super.key});

  @override
  ConsumerState<AuthCompleteScreen> createState() => _AuthCompleteScreenState();
}

class _AuthCompleteScreenState extends ConsumerState<AuthCompleteScreen> {
  bool _redirectScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider).completeOnboarding();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final firebase = ref.read(firebaseServiceProvider);
    final hasAuthSession = firebase.currentUserId != null;
    final verificationRequired =
        hasAuthSession && firebase.isCurrentUserEmailVerificationRequired;
    final stillResolving =
        hasAuthSession &&
        !verificationRequired &&
        (profileState.isLoading || profileState.isGuest);

    if (!_redirectScheduled && !stillResolving) {
      _redirectScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!hasAuthSession) {
          context.go('/login');
          return;
        }
        if (verificationRequired) {
          context.go('/verify-email');
          return;
        }
        ref
            .read(localStorageServiceProvider)
            .setString(Constants.postLogoutRedirectKey, 'false');
        context.go(profileState.needsProfileSetup ? '/profile-setup' : '/home');
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
                    width: 84,
                    height: 84,
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
                      Icons.person_outline,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Аккаунт даярдалып жатат',
                    style: AppTextStyles.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Профилиңиз текшерилип жатат.',
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
