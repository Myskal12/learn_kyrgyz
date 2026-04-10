import 'dart:convert';
import 'dart:io';

void main() {
  final failures = <String>[];
  final warnings = <String>[];

  final root = Directory.current;

  final keyPropertiesFile = File(_join(root.path, 'android', 'key.properties'));
  final keyProperties = keyPropertiesFile.existsSync()
      ? _parseProperties(keyPropertiesFile.readAsLinesSync())
      : <String, String>{};

  if (!keyPropertiesFile.existsSync()) {
    failures.add(
      'Missing android/key.properties. Copy android/key.properties.example and fill real release signing values.',
    );
  } else {
    final requiredKeys = ['storeFile', 'storePassword', 'keyAlias', 'keyPassword'];
    final missingKeys = requiredKeys.where((key) {
      final value = keyProperties[key]?.trim() ?? '';
      return value.isEmpty;
    }).toList();
    if (missingKeys.isNotEmpty) {
      failures.add(
        'android/key.properties is missing: ${missingKeys.join(', ')}.',
      );
    }

    final storeFileValue = keyProperties['storeFile']?.trim() ?? '';
    if (storeFileValue.isNotEmpty) {
      final storeFile = File(_join(root.path, 'android', storeFileValue));
      if (!storeFile.existsSync()) {
        failures.add(
          'Release keystore file does not exist: ${storeFile.path}',
        );
      }
    }
  }

  final googleServicesFile = File(
    _join(root.path, 'android', 'app', 'google-services.json'),
  );
  if (!googleServicesFile.existsSync()) {
    failures.add('Missing android/app/google-services.json.');
  } else {
    final packageName = _readAndroidPackageName(googleServicesFile);
    if (packageName == null || packageName.isEmpty) {
      failures.add(
        'Could not read package_name from android/app/google-services.json.',
      );
    } else if (packageName.startsWith('com.example')) {
      failures.add(
        'android/app/google-services.json still targets example package "$packageName".',
      );
    }
  }

  final duplicateGoogleServices = File(_join(root.path, 'google-services (1).json'));
  if (duplicateGoogleServices.existsSync()) {
    warnings.add(
      'Found extra downloaded file ${duplicateGoogleServices.path}. Remove stale Firebase configs to avoid confusion.',
    );
  }

  final releaseXcconfig = File(_join(root.path, 'ios', 'Flutter', 'Release.xcconfig'));
  if (!releaseXcconfig.existsSync()) {
    failures.add('Missing ios/Flutter/Release.xcconfig.');
  } else {
    final appBundleId = _readXcconfigValue(releaseXcconfig, 'APP_BUNDLE_ID');
    if (appBundleId == null || appBundleId.isEmpty) {
      failures.add('APP_BUNDLE_ID is not set in ios/Flutter/Release.xcconfig.');
    } else if (appBundleId.startsWith('com.example')) {
      failures.add(
        'ios/Flutter/Release.xcconfig still uses example bundle ID "$appBundleId".',
      );
    }
  }

  final iosGoogleServiceInfo = File(
    _join(root.path, 'ios', 'Runner', 'GoogleService-Info.plist'),
  );
  if (!iosGoogleServiceInfo.existsSync()) {
    failures.add('Missing ios/Runner/GoogleService-Info.plist.');
  }

  final firebaseOptionsFile = File(_join(root.path, 'lib', 'firebase_options.dart'));
  if (!firebaseOptionsFile.existsSync()) {
    failures.add('Missing lib/firebase_options.dart.');
  } else {
    final content = firebaseOptionsFile.readAsStringSync();
    final bundleIdMatches =
        RegExp(r"iosBundleId:\s*'([^']+)'").allMatches(content).toList();
    if (bundleIdMatches.isEmpty) {
      failures.add(
        'Could not find iosBundleId values in lib/firebase_options.dart.',
      );
    } else {
      final invalidBundleIds = bundleIdMatches
          .map((match) => match.group(1) ?? '')
          .where((value) => value.startsWith('com.example'))
          .toList();
      if (invalidBundleIds.isNotEmpty) {
        failures.add(
          'lib/firebase_options.dart still contains example Apple bundle IDs: ${invalidBundleIds.join(', ')}.',
        );
      }
    }
  }

  stdout.writeln('Release readiness report');
  stdout.writeln('Project root: ${root.path}');
  stdout.writeln('');

  if (failures.isEmpty) {
    stdout.writeln('PASS: release configuration checks passed.');
  } else {
    stdout.writeln('FAIL: release configuration checks found ${failures.length} issue(s).');
    for (final failure in failures) {
      stdout.writeln('- $failure');
    }
  }

  if (warnings.isNotEmpty) {
    stdout.writeln('');
    stdout.writeln('Warnings:');
    for (final warning in warnings) {
      stdout.writeln('- $warning');
    }
  }

  if (failures.isNotEmpty) {
    exitCode = 1;
  }
}

Map<String, String> _parseProperties(List<String> lines) {
  final values = <String, String>{};
  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final separator = line.indexOf('=');
    if (separator <= 0) continue;
    final key = line.substring(0, separator).trim();
    final value = line.substring(separator + 1).trim();
    values[key] = value;
  }
  return values;
}

String? _readAndroidPackageName(File googleServicesFile) {
  try {
    final payload = jsonDecode(googleServicesFile.readAsStringSync())
        as Map<String, dynamic>;
    final clients = payload['client'];
    if (clients is! List) return null;
    for (final item in clients) {
      if (item is! Map) continue;
      final clientInfo = item['client_info'];
      if (clientInfo is! Map) continue;
      final androidInfo = clientInfo['android_client_info'];
      if (androidInfo is! Map) continue;
      final packageName = androidInfo['package_name']?.toString().trim();
      if (packageName != null && packageName.isNotEmpty) {
        return packageName;
      }
    }
  } catch (_) {
    return null;
  }
  return null;
}

String? _readXcconfigValue(File file, String key) {
  for (final rawLine in file.readAsLinesSync()) {
    final line = rawLine.trim();
    if (!line.startsWith('$key=')) continue;
    return line.substring(key.length + 1).trim();
  }
  return null;
}

String _join(String first, String second, [String? third, String? fourth]) {
  final parts = [first, second, if (third != null) third, if (fourth != null) fourth];
  return parts.join(Platform.pathSeparator);
}
