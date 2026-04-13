import 'app_assets.dart';

const String defaultProfileAvatar = AppAssets.avatarKalpak;

const List<String> profileAvatarPresets = [
  AppAssets.avatarKalpak,
  AppAssets.avatarCasualBoy,
  AppAssets.avatarGirlLight,
  AppAssets.avatarGirlTraditional,
];

String normalizeProfileAvatar(dynamic value) {
  final resolved = _extractAvatarValue(value);
  if (resolved.isEmpty) {
    return defaultProfileAvatar;
  }
  if (profileAvatarPresets.contains(resolved)) {
    return resolved;
  }
  return defaultProfileAvatar;
}

String _extractAvatarValue(dynamic value) {
  if (value is String) {
    return value.trim();
  }
  if (value is Map) {
    const candidates = ['value', 'asset', 'path', 'avatar', 'avatarPath'];
    for (final key in candidates) {
      final raw = value[key];
      if (raw is String && raw.trim().isNotEmpty) {
        return raw.trim();
      }
    }
  }
  return '';
}
