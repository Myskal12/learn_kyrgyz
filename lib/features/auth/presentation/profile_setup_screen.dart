import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/onboarding_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/avatar_presets.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../shared/widgets/sticky_bottom_action_bar.dart';
import '../../profile/providers/user_profile_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _nameController;
  String? _localError;
  bool _initialized = false;
  String _selectedAvatar = defaultProfileAvatar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nickname = _nameController.text.trim();
    if (nickname.isEmpty) {
      setState(() => _localError = 'Атыңызды жазыңыз.');
      return;
    }

    setState(() => _localError = null);
    await ref
        .read(userProfileProvider)
        .completeProfileSetup(nickname, avatar: _selectedAvatar);
    await ref
        .read(localStorageServiceProvider)
        .setString(Constants.postLogoutRedirectKey, 'false');
    await ref.read(onboardingProvider).completeOnboarding();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    if (!_initialized) {
      final initialName =
          profileState.suggestedNickname ?? profileState.profile.nickname;
      if (initialName.trim().isNotEmpty && initialName.trim() != 'Колдонуучу') {
        _nameController.text = initialName.trim();
      }
      _selectedAvatar = normalizeProfileAvatar(profileState.profile.avatar);
      _initialized = true;
    }

    if (!profileState.isLoading && profileState.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/login');
        }
      });
    }

    return AppShell(
      title: '',
      showTopNav: false,
      showBottomNav: false,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/login',
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
                            ProfileAvatar(avatar: _selectedAvatar),
                            const SizedBox(height: 16),
                            Text(
                              'Атыңызды коюңуз',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Профилде ушул ысым жана аватар көрүнөт.',
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
                            Text('Ат', style: AppTextStyles.body),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Мисалы: Айбек',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppColors.muted,
                                ),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text('Аватар', style: AppTextStyles.body),
                            const SizedBox(height: 8),
                            AvatarPresetPicker(
                              selectedAvatar: _selectedAvatar,
                              onSelected: (value) {
                                setState(() => _selectedAvatar = value);
                              },
                            ),
                            const SizedBox(height: 8),
                            const AvatarSelectionHint(
                              text:
                                  'Кийин муну жөндөөлөрдөн дагы алмаштырсаңыз болот.',
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
                    AppButton(
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      onPressed: profileState.isLoading ? null : _save,
                      child: Text(profileState.isLoading ? '...' : 'Улантуу'),
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
