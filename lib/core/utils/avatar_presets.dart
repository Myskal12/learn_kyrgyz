import 'app_assets.dart';

const String defaultProfileAvatar = AppAssets.avatarKalpak;

const List<String> profileAvatarPresets = [
  AppAssets.avatarKalpak,
  AppAssets.avatarCasualBoy,
  AppAssets.avatarGirlLight,
  AppAssets.avatarGirlTraditional,
];

String normalizeProfileAvatar(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return defaultProfileAvatar;
  }
  return trimmed;
}
