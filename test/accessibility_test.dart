import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

void main() {
  late WalletSources sources;

  setUpAll(() => sources = memorySources());
  tearDownAll(() => sources.dispose());

  List<FakeWallet> twoWallets() => [
    FakeWallet('home', 'Home node', balance: 152300)
      ..transactions = [
        tx(
          'zap',
          sats: 21000,
          incoming: true,
          minutesAgo: 2,
          description: 'Zap from bob',
        ),
        tx('coffee', sats: 5400, minutesAgo: 30, description: 'Coffee'),
        tx('paid', sats: 40000, incoming: true, days: 1),
      ],
    FakeWallet('offline', 'Offline node', error: BalanceError.unreachable)
      ..activityError = ActivityError.unreachable,
  ];

  Future<void> expectGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final brightness in Brightness.values) {
    for (final (name, size) in [
      ('phone', phoneSize),
      ('desktop', desktopSize),
    ]) {
      testWidgets('home meets the guidelines, $name, ${brightness.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpLumen(
          tester,
          sources,
          wallets: twoWallets(),
          size: size,
          brightness: brightness,
        );
        await expectGuidelines(tester);
        handle.dispose();
      }, variant: _platformFor(size));

      testWidgets('welcome meets the guidelines, $name, ${brightness.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpLumen(
          tester,
          sources,
          wallets: [],
          size: size,
          brightness: brightness,
        );
        await expectGuidelines(tester);
        handle.dispose();
      }, variant: _platformFor(size));
    }
  }

  Future<void> openInvoice(WidgetTester tester) async {
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '21000');
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    for (final (name, size) in [
      ('phone', phoneSize),
      ('desktop', desktopSize),
    ]) {
      testWidgets('receive meets the guidelines, $name, ${brightness.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        final wallets = twoWallets();
        await pumpLumen(
          tester,
          sources,
          wallets: wallets,
          size: size,
          brightness: brightness,
        );

        await tester.tap(find.text('Receive'));
        await tester.pumpAndSettle();
        await expectGuidelines(tester);

        await tester.tap(find.text('Into'));
        await tester.pumpAndSettle();
        expect(find.byType(MenuItemButton), findsNWidgets(2));
        await expectGuidelines(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '21000');
        await tester.tap(find.text('Create invoice'));
        await tester.pumpAndSettle();
        await expectGuidelines(tester);

        wallets.first.pay();
        await tester.pumpAndSettle();
        await expectGuidelines(tester);
        handle.dispose();
      }, variant: _platformFor(size));
    }
  }

  for (final (name, size) in [('phone', phoneSize), ('desktop', desktopSize)]) {
    testWidgets('receive lays out at 200% text, $name', (tester) async {
      final wallets = twoWallets();
      await pumpLumen(
        tester,
        sources,
        wallets: wallets,
        size: size,
        textScale: 2,
      );

      await openInvoice(tester);
      expect(tester.takeException(), isNull, reason: 'invoice');

      wallets.first.pay();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'paid');
      expect(find.text('Payment received'), findsOneWidget);
    }, variant: _platformFor(size));
  }

  Future<void> reviewPayment(WidgetTester tester) async {
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      fakeBolt11(5400, description: 'Coffee at the corner shop'),
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    for (final (name, size) in [
      ('phone', phoneSize),
      ('desktop', desktopSize),
    ]) {
      testWidgets('send meets the guidelines, $name, ${brightness.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpLumen(
          tester,
          sources,
          wallets: twoWallets(),
          size: size,
          brightness: brightness,
        );

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();
        await expectGuidelines(tester);

        await tester.tap(find.text('Review'));
        await tester.pumpAndSettle();
        expect(
          find.text('Paste a Lightning invoice or a Lightning address.'),
          findsOneWidget,
        );
        await expectGuidelines(tester);

        await tester.tap(find.text('Pay from'));
        await tester.pumpAndSettle();
        await expectGuidelines(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        if (size == phoneSize) {
          await tester.tap(find.byTooltip('Back'));
        } else {
          await tester.tap(find.byTooltip('Close'));
        }
        await tester.pumpAndSettle();

        await reviewPayment(tester);
        await expectGuidelines(tester);

        await tester.tap(find.text('Send 5,400 sats'));
        await tester.pumpAndSettle();
        expect(find.text('Payment sent'), findsOneWidget);
        await expectGuidelines(tester);
        handle.dispose();
      }, variant: _platformFor(size));
    }
  }

  for (final (name, size) in [('phone', phoneSize), ('desktop', desktopSize)]) {
    testWidgets('send lays out at 200% text, $name', (tester) async {
      await pumpLumen(
        tester,
        sources,
        wallets: twoWallets(),
        size: size,
        textScale: 2,
      );

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'form');
      await tester.tap(find.byTooltip(size == phoneSize ? 'Back' : 'Close'));
      await tester.pumpAndSettle();

      await reviewPayment(tester);
      expect(tester.takeException(), isNull, reason: 'review');

      await tester.ensureVisible(find.text('Send 5,400 sats'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send 5,400 sats'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'sent');
      expect(find.text('Payment sent'), findsOneWidget);
    }, variant: _platformFor(size));
  }

  testWidgets('the review reads the amount with its heading', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: twoWallets());

    await reviewPayment(tester);

    expect(
      find.bySemanticsLabel('You are sending\n5,400 sats'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('From\nHome node'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Note\nCoffee at the corner shop'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('a wallet row reads as one item with its kind and unit', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: twoWallets());

    expect(
      find.bySemanticsLabel(
        RegExp(r'^Home node\nLightning via NWC\n152,300 sats$'),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Offline node\nLightning via NWC\n.*Unavailable$'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('the total is one live region with a refresh action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: twoWallets());

    final total = tester.getSemantics(
      find.bySemanticsLabel(
        RegExp(
          r'^Total balance\n152,300 sats\n1 wallet is not counted: its balance is unavailable\.$',
        ),
      ),
    );
    expect(total.flagsCollection.isLiveRegion, isTrue);
    expect(total.getSemanticsData().customSemanticsActionIds, isNotEmpty);
    handle.dispose();
  });

  testWidgets('an activity row reads as one item with its direction', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: twoWallets());

    expect(
      find.bySemanticsLabel(
        RegExp(r'^Coffee\nHome node, 30 min ago\nsent 5,400 sats$'),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Received\nHome node, Yesterday\nreceived 40,000 sats$'),
      ),
      findsOneWidget,
    );
    expect(
      find.text('Activity from 1 wallet is not shown: it could not be loaded.'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('activity times keep up while the screen stays open', (
    tester,
  ) async {
    final wallet = FakeWallet('home', 'Home node')
      ..transactions = [tx('zap', incoming: true)];
    await pumpLumen(tester, sources, wallets: [wallet]);
    expect(find.text('Home node, Just now'), findsOneWidget);

    await tester.pump(const Duration(minutes: 1));
    expect(find.text('Home node, 1 min ago'), findsOneWidget);
  });

  testWidgets('desktop activity is a table with column headers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: twoWallets(), size: desktopSize);

    expect(find.byType(Table), findsOneWidget);
    for (final header in ['Description', 'Wallet', 'Date', 'Amount']) {
      final node = tester.getSemantics(find.text(header));
      expect(node.role, SemanticsRole.columnHeader, reason: header);
    }
    expect(find.bySemanticsLabel('received 21,000 sats'), findsOneWidget);
    handle.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('a wallet without activity permission says how to fix it', (
    tester,
  ) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [
        FakeWallet('ro', 'Read only', balance: 10)
          ..activityError = ActivityError.noPermission,
      ],
    );

    await tester.tap(find.text('Read only'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This connection cannot list transactions. In your wallet, create a new connection that allows listing transactions.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the short Add link is announced as Add wallet', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: twoWallets());

    final add = tester.getSemantics(find.bySemanticsLabel('Add wallet'));
    expect(add.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  testWidgets('the screen title names the route and takes focus', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: twoWallets());

    await tester.tap(find.text('Home node'));
    await tester.pumpAndSettle();

    final title = tester.getSemantics(find.bySemanticsLabel('Home node').last);
    expect(title.flagsCollection.namesRoute, isTrue);
    expect(title.flagsCollection.isHeader, isTrue);
    expect(title.flagsCollection.isFocused.toBoolOrNull(), isTrue);
    handle.dispose();
  });

  for (final (name, size) in [('phone', phoneSize), ('desktop', desktopSize)]) {
    testWidgets('every screen lays out at 200% text, $name', (tester) async {
      await pumpLumen(
        tester,
        sources,
        wallets: twoWallets(),
        size: size,
        textScale: 2,
      );
      expect(tester.takeException(), isNull, reason: 'home');

      await tester.ensureVisible(find.text('Offline node').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Offline node').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'wallet');
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.byTooltip('Offline node options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'rename dialog');
    }, variant: _platformFor(size));

    testWidgets('welcome and connect lay out at 200% text, $name', (
      tester,
    ) async {
      await pumpLumen(tester, sources, wallets: [], size: size, textScale: 2);
      expect(tester.takeException(), isNull, reason: 'welcome');

      await tester.tap(find.text('Add a wallet'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'connect');
    }, variant: _platformFor(size));
  }

  for (final (name, size) in [('phone', phoneSize), ('desktop', desktopSize)]) {
    testWidgets('welcome and connect fit without scrolling, $name', (
      tester,
    ) async {
      await pumpLumen(tester, sources, wallets: [], size: size);
      expect(_maxScroll(tester), 0, reason: 'welcome');

      await tester.tap(find.text('Add a wallet'));
      await tester.pumpAndSettle();
      expect(_maxScroll(tester), 0, reason: 'connect');
      final button = tester.getRect(
        find.widgetWithText(FilledButton, 'Connect'),
      );
      expect(button.bottom, lessThanOrEqualTo(size.height - 32));
    }, variant: _platformFor(size));
  }

  testWidgets('a connection without balance permission says how to fix it', (
    tester,
  ) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [
        FakeWallet('ro', 'Read only', error: BalanceError.noPermission),
      ],
    );

    await tester.tap(find.text('Read only'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This connection cannot read the balance. In your wallet, create a new connection that allows reading the balance.',
      ),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('an invalid connection string shows an inline fix', (
    tester,
  ) async {
    await pumpLumen(tester, sources, wallets: []);

    await tester.tap(find.text('Add a wallet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'lnbc1...');
    await tester.enterText(find.byType(TextField).last, 'Home node');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This is not an NWC connection string. It should start with nostr+walletconnect://',
      ),
      findsOneWidget,
    );
  });
}

double _maxScroll(WidgetTester tester) => tester
    .state<ScrollableState>(
      find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    )
    .position
    .maxScrollExtent;

/// Desktop runs as macOS, whose default compact density shrinks controls.
TestVariant<Object?> _platformFor(Size size) => size == desktopSize
    ? TargetPlatformVariant.only(TargetPlatform.macOS)
    : const DefaultTestVariant();
