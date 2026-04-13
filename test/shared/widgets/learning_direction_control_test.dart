import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_kyrgyz/app/providers/app_providers.dart';
import 'package:learn_kyrgyz/app/providers/learning_direction_provider.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/core/utils/learning_direction.dart';
import 'package:learn_kyrgyz/shared/widgets/learning_direction_control.dart';

class FakeLocalStorageService implements LocalStorageService {
  FakeLocalStorageService([Map<String, String>? initialValues])
    : values = {...?initialValues};

  final Map<String, String> values;

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('switches the study direction and persists it', (tester) async {
    final storage = FakeLocalStorageService({'learning_direction': 'ky_to_en'});
    final container = ProviderContainer(
      overrides: [localStorageServiceProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: LearningDirectionControl()),
        ),
      ),
    );
    await tester.pump();

    expect(container.read(learningDirectionProvider), LearningDirection.kyToEn);

    await tester.tap(find.byKey(const Key('direction-option-en-to-ky')));
    await tester.pump();

    expect(container.read(learningDirectionProvider), LearningDirection.enToKy);
    expect(storage.values['learning_direction'], 'en_to_ky');
  });
}
