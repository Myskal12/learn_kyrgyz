import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';
import '../../core/utils/avatar_presets.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.avatar, this.size = 72});

  final String avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeProfileAvatar(avatar);
    final isAssetAvatar = normalized.startsWith('assets/');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: isAssetAvatar
            ? Image.asset(
                normalized,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Text(
                normalized,
                style: TextStyle(
                  fontSize: size * 0.38,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class AvatarPresetPicker extends StatelessWidget {
  const AvatarPresetPicker({
    super.key,
    required this.selectedAvatar,
    required this.onSelected,
  });

  final String selectedAvatar;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: profileAvatarPresets.map((avatar) {
        final selected = avatar == selectedAvatar;
        final isAssetAvatar = avatar.startsWith('assets/');
        return InkWell(
          onTap: () => onSelected(avatar),
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isAssetAvatar)
                  ClipOval(
                    child: Image.asset(
                      avatar,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Text(avatar, style: const TextStyle(fontSize: 24)),
                if (selected)
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AvatarSelectionHint extends StatelessWidget {
  const AvatarSelectionHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.muted.copyWith(fontSize: 13));
  }
}
