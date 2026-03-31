import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_kyrgyz/app/providers/app_providers.dart';
import 'package:learn_kyrgyz/core/services/local_storage_service.dart';
import 'package:learn_kyrgyz/shared/widgets/adaptive_panel_grid.dart';
import 'package:learn_kyrgyz/shared/widgets/app_bottom_nav.dart';
import 'package:learn_kyrgyz/shared/widgets/app_card.dart';
import 'package:learn_kyrgyz/shared/widgets/app_shell.dart';

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

  testWidgets(
    'shared mobile shell stays stable across narrow widths and text scales',
    (tester) async {
      final storage = FakeLocalStorageService({
        'learning_direction': 'en_to_ky',
      });

      for (final width in [320.0, 360.0, 430.0]) {
        for (final scale in [1.0, 1.3, 1.6]) {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                localStorageServiceProvider.overrideWithValue(storage),
              ],
              child: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 812),
                  textScaler: TextScaler.linear(scale),
                ),
                child: MaterialApp(
                  home: AppShell(
                    title: 'Узун аталыштагы мобилдик экран',
                    subtitle: 'Адаптивдүү көрүү жана стресс текшерүү',
                    activeTab: AppTab.practice,
                    navigationMode: AppShellNavigationMode.back,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [
                        AdaptivePanelGrid(
                          maxColumns: 3,
                          minItemWidth: 92,
                          children: [
                            AppCard(
                              padding: EdgeInsets.all(16),
                              child: Text('Күнүмдүк максат'),
                            ),
                            AppCard(
                              padding: EdgeInsets.all(16),
                              child: Text('Кайра кароо'),
                            ),
                            AppCard(
                              padding: EdgeInsets.all(16),
                              child: Text('Өздөштүрүлгөн сөздөр'),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        AppCard(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Кайсы аракет азыр маанилүү экенин дароо көрүү',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isNull,
            reason: 'width=$width scale=$scale',
          );
          expect(find.byType(AppBottomNav), findsOneWidget);
        }
      }
    },
  );
}
