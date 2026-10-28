import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

void main() {
  late WalletSources sources;

  setUp(() => sources = memorySources());
  tearDown(() => sources.dispose());

  final defaults = LiquidWalletSource.defaultServers[ChainNetwork.liquid]!;
  const custom = LiquidServers(
    waterfalls: 'https://waterfalls.example/api',
    esplora: 'https://esplora.example/api',
  );

  /// Saving refreshes the wallets, whose history store runs on real time.
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<FakeWallet> openSettings(
    WidgetTester tester, {
    Size size = phoneSize,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    final wallet = FakeWallet.liquid('savings', 'Savings');
    await pumpLumen(
      tester,
      sources,
      wallets: [wallet],
      size: size,
      brightness: brightness,
      textScale: textScale,
    );
    await tapAndSettle(
      tester,
      size == desktopSize ? find.text('Settings') : find.byTooltip('Settings'),
    );
    return wallet;
  }

  String fieldText(WidgetTester tester, int index) => tester
      .widget<TextField>(find.byType(TextField).at(index))
      .controller!
      .text;

  bool focused(WidgetTester tester, int index) => tester
      .widget<TextField>(find.byType(TextField).at(index))
      .focusNode!
      .hasFocus;

  testWidgets('Settings opens the Liquid servers, the defaults at first', (
    tester,
  ) async {
    await openSettings(tester);
    expect(find.text('Servers'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Testnet servers'), findsNothing);

    await tapAndSettle(tester, find.text('Servers'));
    expect(find.text('Liquid servers'), findsOneWidget);
    expect(fieldText(tester, 0), defaults.waterfalls);
    expect(fieldText(tester, 1), defaults.esplora);
  });

  testWidgets('saved servers are used by the Liquid wallets, refreshed', (
    tester,
  ) async {
    final wallet = await openSettings(tester);
    await tapAndSettle(tester, find.text('Servers'));
    final fetches = wallet.fetchCount;

    await tester.enterText(
      find.byType(TextField).at(0),
      ' https://waterfalls.example/api/ ',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'https://esplora.example/api',
    );
    await tapAndSettle(tester, find.text('Save'));

    expect(
      await tester.runAsync(() => sources.liquid.servers(ChainNetwork.liquid)),
      custom,
    );
    expect(find.text('Liquid servers'), findsNothing);
    expect(find.text('Custom'), findsOneWidget);
    expect(wallet.fetchCount, greaterThan(fetches));
  });

  testWidgets('an empty Waterfalls syncs through Esplora only', (tester) async {
    await openSettings(tester);
    await tapAndSettle(tester, find.text('Servers'));

    await tester.enterText(find.byType(TextField).at(0), '');
    await tapAndSettle(tester, find.text('Save'));

    expect(
      await tester.runAsync(() => sources.liquid.servers(ChainNetwork.liquid)),
      LiquidServers(esplora: defaults.esplora),
    );
  });

  testWidgets('a URL that is not one, or no Esplora, is shown inline', (
    tester,
  ) async {
    await openSettings(tester);
    await tapAndSettle(tester, find.text('Servers'));

    await tester.enterText(find.byType(TextField).at(0), 'waterfalls.example');
    await tester.enterText(find.byType(TextField).at(1), ' ');
    await tapAndSettle(tester, find.text('Save'));

    expect(
      find.text('Enter a full URL, such as https://liquid.network/api'),
      findsOneWidget,
    );
    expect(
      find.text('Enter an Esplora URL, such as https://liquid.network/api'),
      findsOneWidget,
    );
    expect(focused(tester, 0), isTrue);
    expect(find.text('Liquid servers'), findsOneWidget);
    expect(
      await tester.runAsync(() => sources.liquid.servers(ChainNetwork.liquid)),
      defaults,
    );

    await tester.enterText(
      find.byType(TextField).at(0),
      'https://w.example?x=1',
    );
    await tester.enterText(find.byType(TextField).at(1), 'ftp://e.example');
    await tapAndSettle(tester, find.text('Save'));
    expect(
      find.text('Enter a full URL, such as https://liquid.network/api'),
      findsNWidgets(2),
    );
  });

  testWidgets('the defaults come back from one button', (tester) async {
    await tester.runAsync(
      () => sources.liquid.setServers(ChainNetwork.liquid, custom),
    );
    await openSettings(tester);
    expect(find.text('Custom'), findsOneWidget);
    await tapAndSettle(tester, find.text('Servers'));
    expect(fieldText(tester, 0), custom.waterfalls);

    await tapAndSettle(tester, find.text('Use the default servers'));
    expect(fieldText(tester, 0), defaults.waterfalls);
    expect(fieldText(tester, 1), defaults.esplora);
    await tapAndSettle(tester, find.text('Save'));

    expect(find.text('Default'), findsOneWidget);
    expect(
      await tester.runAsync(() => sources.liquid.servers(ChainNetwork.liquid)),
      defaults,
    );
  });

  testWidgets('testnet has its own servers where it is enabled', (
    tester,
  ) async {
    await tester.runAsync(sources.dispose);
    sources = (await tester.runAsync(
      () async => memorySources(
        liquidNetworks: const {ChainNetwork.liquid, ChainNetwork.liquidTestnet},
      ),
    ))!;
    await openSettings(tester);

    await tapAndSettle(tester, find.text('Testnet servers'));
    expect(find.text('Liquid testnet servers'), findsOneWidget);
    expect(
      fieldText(tester, 1),
      LiquidWalletSource.defaultServers[ChainNetwork.liquidTestnet]!.esplora,
    );
  });

  for (final (name, size) in [('phone', phoneSize), ('desktop', desktopSize)]) {
    for (final brightness in Brightness.values) {
      testWidgets('the Liquid servers meet the guidelines, $name, '
          '${brightness.name}', (tester) async {
        final handle = tester.ensureSemantics();
        await openSettings(tester, size: size, brightness: brightness);
        await expectGuidelines(tester);
        await tapAndSettle(tester, find.text('Servers'));
        await expectGuidelines(tester);
        await tester.enterText(find.byType(TextField).at(1), '');
        await tapAndSettle(tester, find.text('Save'));
        expect(
          find.text('Enter an Esplora URL, such as https://liquid.network/api'),
          findsOneWidget,
        );
        await expectGuidelines(tester);
        handle.dispose();
      }, variant: _platformFor(size));
    }

    testWidgets('the Liquid servers lay out at 200% text, $name', (
      tester,
    ) async {
      await openSettings(tester, size: size, textScale: 2);
      expect(tester.takeException(), isNull, reason: 'settings');
      await tapAndSettle(tester, find.text('Servers'));
      expect(tester.takeException(), isNull, reason: 'servers');
      await tester.enterText(find.byType(TextField).at(0), 'nope');
      await tapAndSettle(tester, find.text('Save'));
      expect(tester.takeException(), isNull, reason: 'error');
      expect(
        find.text('Enter a full URL, such as https://liquid.network/api'),
        findsOneWidget,
      );
    }, variant: _platformFor(size));
  }
}

TestVariant<Object?> _platformFor(Size size) => size == desktopSize
    ? TargetPlatformVariant.only(TargetPlatform.macOS)
    : const DefaultTestVariant();
