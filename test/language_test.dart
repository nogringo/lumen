import 'package:flutter/semantics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/app.dart';
import 'package:lumen/l10n/generated/app_localizations.dart';
import 'package:lumen/screens/lock_screen.dart';
import 'package:lumen/settings/language.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

void main() {
  late WalletSources sources;

  setUpAll(() => sources = memorySources());
  tearDownAll(() => sources.dispose());
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  List<FakeWallet> oneWallet() => [
    FakeWallet('home', 'Home node', balance: 21000),
  ];

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openLanguages(
    WidgetTester tester, {
    Size size = phoneSize,
  }) async {
    await tapAndSettle(
      tester,
      size == desktopSize ? find.text('Settings') : find.byTooltip('Settings'),
    );
    await tapAndSettle(tester, find.text('Language'));
  }

  test('every supported language has a name in its own words', () {
    expect(
      languageNames.keys.toSet(),
      AppLocalizations.supportedLocales.toSet(),
    );
  });

  testWidgets('picking a language switches Lumen to it and saves it', (
    tester,
  ) async {
    final store = MemoryLanguageStore();
    await pumpLumen(
      tester,
      sources,
      wallets: oneWallet(),
      language: LanguageSetting(store),
    );
    await openLanguages(tester);
    expect(find.text('Device language'), findsNWidgets(2));

    await tapAndSettle(tester, find.text('Français'));
    expect(find.text('Réglages'), findsOneWidget);
    expect(find.text('Langue'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(store.tag, 'fr');

    await tapAndSettle(tester, find.text('Langue'));
    await tapAndSettle(tester, find.text("Langue de l'appareil"));
    expect(find.text('Settings'), findsOneWidget);
    expect(store.tag, isNull);
  });

  testWidgets('a regional language is saved with its region', (tester) async {
    final store = MemoryLanguageStore();
    await pumpLumen(
      tester,
      sources,
      wallets: oneWallet(),
      language: LanguageSetting(store),
    );
    await openLanguages(tester);

    await tapAndSettle(tester, find.text('Português (Brasil)'));
    expect(find.text('Configurações'), findsOneWidget);
    expect(store.tag, 'pt-BR');
  });

  testWidgets('Cancel keeps the language', (tester) async {
    final store = MemoryLanguageStore('de');
    final language = LanguageSetting(store);
    await tester.runAsync(language.load);
    await pumpLumen(tester, sources, wallets: oneWallet(), language: language);
    await tapAndSettle(tester, find.byTooltip('Einstellungen'));
    await tapAndSettle(tester, find.text('Sprache'));

    await tapAndSettle(tester, find.text('Abbrechen'));
    expect(find.text('Einstellungen'), findsOneWidget);
    expect(store.tag, 'de');
  });

  testWidgets('the saved language applies from launch, lock screen included', (
    tester,
  ) async {
    final language = LanguageSetting(MemoryLanguageStore('ja'));
    final wallets = await tester.runAsync(() => loadedController(oneWallet()));
    final gate = testGate(sources, wallets!);
    await tester.runAsync(() async {
      await wallets.refreshAll();
      await language.load();
      await gate.start();
      await gate.enableLock('correct horse battery');
      await gate.lockNow();
    });
    await tester.pumpWidget(LumenApp(gate: gate, language: language));
    await tester.pumpAndSettle();

    expect(
      Localizations.localeOf(tester.element(find.byType(LockScreen))),
      const Locale('ja'),
    );
  });

  testWidgets('a saved language Lumen no longer has follows the device', (
    tester,
  ) async {
    final language = LanguageSetting(MemoryLanguageStore('xx'));
    await tester.runAsync(language.load);
    expect(language.locale, isNull);
  });

  testWidgets('each language reads as one choice, in its own language', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: oneWallet());
    await openLanguages(tester);

    final german = tester.getSemantics(find.text('Deutsch'));
    expect(
      german,
      isSemantics(
        label: 'Deutsch',
        hasCheckedState: true,
        isChecked: false,
        isInMutuallyExclusiveGroup: true,
        isButton: false,
        hasTapAction: true,
        isFocusable: true,
      ),
    );
    expect(
      german.getSemanticsData().attributedLabel.attributes,
      contains(
        isA<LocaleStringAttribute>().having(
          (attribute) => attribute.locale,
          'locale',
          const Locale('de'),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Device language').last),
      isSemantics(isChecked: true, isInMutuallyExclusiveGroup: true),
    );
    handle.dispose();
  });

  for (final brightness in Brightness.values) {
    for (final (name, size) in [
      ('phone', phoneSize),
      ('desktop', desktopSize),
    ]) {
      testWidgets(
        'the language picker meets the guidelines, $name, ${brightness.name}',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpLumen(
            tester,
            sources,
            wallets: oneWallet(),
            size: size,
            brightness: brightness,
          );
          await openLanguages(tester, size: size);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        },
        variant: size == desktopSize
            ? TargetPlatformVariant.only(TargetPlatform.macOS)
            : const DefaultTestVariant(),
      );
    }
  }

  testWidgets('the language picker lays out and scrolls at 200% text', (
    tester,
  ) async {
    final store = MemoryLanguageStore();
    await pumpLumen(
      tester,
      sources,
      wallets: oneWallet(),
      textScale: 2,
      language: LanguageSetting(store),
    );
    await openLanguages(tester);
    expect(tester.takeException(), isNull);

    await tapAndSettle(tester, find.text('简体中文'));
    expect(tester.takeException(), isNull);
    expect(store.tag, 'zh');
  });
}
