import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

final _qr = find.bySemanticsLabel(RegExp(r'^QR code of the Lightning invoice'));
final _liquidQr = find.bySemanticsLabel(
  RegExp(r'^QR code of the Liquid address'),
);

void main() {
  late WalletSources sources;

  setUpAll(() => sources = memorySources());
  tearDownAll(() => sources.dispose());

  Future<void> createInvoice(WidgetTester tester, String amount) async {
    await tester.enterText(find.byType(TextField), amount);
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
  }

  testWidgets('receives a payment on a phone', (tester) async {
    final handle = tester.ensureSemantics();
    final haptics = watchHaptics(tester);
    final wallet = FakeWallet('home', 'Home node', balance: 100);
    await pumpLumen(tester, sources, wallets: [wallet]);

    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();
    expect(find.text('Into'), findsOneWidget);
    expect(find.text('Lightning address'), findsNothing);

    await createInvoice(tester, '21000');
    expect(wallet.invoiceAmounts, [21000]);
    expect(
      tester.getSemantics(_qr).label,
      'QR code of the Lightning invoice for 21,000 sats. The invoice text is below, with a copy button.',
    );
    expect(find.byTooltip('Copy invoice'), findsOneWidget);
    expect(find.byTooltip('Share invoice'), findsOneWidget);
    expect(find.text('Waiting for payment'), findsOneWidget);
    expect(find.text('Expires in 60 minutes'), findsOneWidget);
    expect(haptics, isEmpty);

    final fetchesBefore = wallet.fetchCount;
    wallet.balance = 21100;
    wallet.pay();
    await tester.pumpAndSettle();
    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('Into Home node'), findsOneWidget);
    expect(haptics, ['HapticFeedbackType.successNotification']);
    expect(wallet.fetchCount, fetchesBefore + 1);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Total balance'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('an empty amount says how to fix it', (tester) async {
    final wallet = FakeWallet('home', 'Home node');
    await pumpLumen(tester, sources, wallets: [wallet]);
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();

    await createInvoice(tester, '0');

    expect(find.text('Enter an amount of at least 1 sat.'), findsOneWidget);
    expect(wallet.invoiceAmounts, isEmpty);
  });

  testWidgets('a connection without receive permission says how to fix it', (
    tester,
  ) async {
    final wallet = FakeWallet('home', 'Home node')
      ..receiveError = ReceiveError.noPermission;
    await pumpLumen(tester, sources, wallets: [wallet]);
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();

    await createInvoice(tester, '500');

    expect(
      find.text(
        'This connection cannot create invoices. In your wallet, create a new connection that allows receiving payments.',
      ),
      findsOneWidget,
    );
    expect(find.text('Create invoice'), findsOneWidget);
  });

  testWidgets('a wallet screen preselects its wallet', (tester) async {
    final home = FakeWallet('home', 'Home node');
    final phone = FakeWallet('phone', 'Phone wallet');
    await pumpLumen(tester, sources, wallets: [home, phone]);

    await tester.tap(find.text('Phone wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();
    await createInvoice(tester, '700');

    expect(phone.invoiceAmounts, [700]);
    expect(home.invoiceAmounts, isEmpty);
  });

  testWidgets('choosing another wallet makes a new invoice in it', (
    tester,
  ) async {
    final home = FakeWallet('home', 'Home node');
    final phone = FakeWallet('phone', 'Phone wallet');
    await pumpLumen(tester, sources, wallets: [home, phone]);
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();
    await createInvoice(tester, '300');

    await tester.tap(find.text('Home node').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phone wallet').last);
    await tester.pumpAndSettle();

    expect(home.invoiceAmounts, [300]);
    expect(phone.invoiceAmounts, [300]);
    expect(_qr, findsOneWidget);
  });

  testWidgets('an expired invoice is replaced in one tap', (tester) async {
    final wallet = FakeWallet('home', 'Home node')
      ..invoiceLifetime = const Duration(seconds: -1);
    await pumpLumen(tester, sources, wallets: [wallet]);
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();

    await createInvoice(tester, '1000');
    expect(_qr, findsNothing);
    expect(
      find.text(
        'This invoice expired. Create a new one to receive this payment.',
      ),
      findsOneWidget,
    );

    wallet.invoiceLifetime = const Duration(hours: 1);
    await tester.tap(find.text('New invoice'));
    await tester.pumpAndSettle();
    expect(wallet.invoiceAmounts, [1000, 1000]);
    expect(_qr, findsOneWidget);
  });

  testWidgets('edit amount goes back to the amount field', (tester) async {
    final wallet = FakeWallet('home', 'Home node');
    await pumpLumen(tester, sources, wallets: [wallet]);
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();
    await createInvoice(tester, '1000');

    await tester.tap(find.text('Edit amount'));
    await tester.pumpAndSettle();
    await createInvoice(tester, '2000');

    expect(wallet.invoiceAmounts, [1000, 2000]);
  });

  testWidgets('copy puts the whole invoice on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final wallet = FakeWallet('home', 'Home node');
    await pumpLumen(tester, sources, wallets: [wallet]);
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();
    await createInvoice(tester, '42');

    await tester.tap(find.byTooltip('Copy invoice'));
    await tester.pumpAndSettle();

    expect(copied, startsWith('lnbc42n1p'));
    expect(copied, hasLength(greaterThan(200)));
  });

  testWidgets('a Lightning address can be copied and shown as a QR code', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final home = FakeWallet(
      'home',
      'Home node',
      lightningAddress: 'satoshi@example.com',
    );
    final phone = FakeWallet('phone', 'Phone wallet');
    await pumpLumen(tester, sources, wallets: [home, phone]);
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Lightning address\nsatoshi@example.com'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Copy address'));
    await tester.pumpAndSettle();
    expect(copied, 'satoshi@example.com');

    await tester.tap(find.byTooltip('Show QR code'));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(
        'QR code of the Lightning address satoshi@example.com',
      ),
      findsOneWidget,
    );
    expect(find.text('Share address'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Share address'), findsNothing);

    await tester.tap(find.text('Home node').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phone wallet').last);
    await tester.pumpAndSettle();
    expect(find.text('satoshi@example.com'), findsNothing);
    handle.dispose();
  });

  testWidgets('the wallet screen shows its Lightning address', (tester) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [
        FakeWallet(
          'home',
          'Home node',
          lightningAddress: 'satoshi@example.com',
        ),
        FakeWallet('phone', 'Phone wallet'),
      ],
    );

    await tester.tap(find.text('Home node'));
    await tester.pumpAndSettle();
    expect(find.text('satoshi@example.com'), findsOneWidget);
    expect(find.byTooltip('Copy address'), findsOneWidget);
    await tester.tap(find.byTooltip('Show QR code'));
    await tester.pumpAndSettle();
    expect(find.text('Share address'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phone wallet'));
    await tester.pumpAndSettle();
    expect(find.text('Lightning address'), findsNothing);
  });

  testWidgets(
    'the wallet menu focuses the chosen wallet and Escape closes only it',
    (tester) async {
      await pumpLumen(
        tester,
        sources,
        wallets: [
          FakeWallet('home', 'Home node', balance: 152300),
          FakeWallet('phone', 'Phone wallet', balance: 4200),
        ],
        size: desktopSize,
      );
      await tester.tap(find.text('Receive'));
      await tester.pumpAndSettle();
      final picker = tester.getRect(find.byType(MenuAnchor));

      await tester.tap(find.text('Into'));
      await tester.pumpAndSettle();
      final items = find.byType(MenuItemButton);
      expect(items, findsNWidgets(2));
      expect(tester.getSize(items.first).width, picker.width - 12);
      expect(
        find.descendant(of: items.last, matching: find.text('4,200')),
        findsOneWidget,
      );
      expect(_focused(tester, items.first), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(items, findsNothing);
      expect(find.byType(Dialog), findsOneWidget);
      expect(_focused(tester, find.byType(MenuAnchor)), isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  group('a Liquid wallet', () {
    testWidgets('shows an address, then the payment until it confirms', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final haptics = watchHaptics(tester);
      final wallet = FakeWallet.liquid('savings', 'Savings');
      await pumpLumen(tester, sources, wallets: [wallet]);

      await tester.tap(find.text('Receive'));
      await tester.pumpAndSettle();
      expect(wallet.addressCount, 1);
      expect(find.byType(TextField), findsNothing);
      expect(
        tester.getSemantics(_liquidQr).label,
        'QR code of the Liquid address. The address is below, with a copy button.',
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'^Address lq1q, qvxk, 052k, f3qt, .*, km7c, v$'),
        ),
        findsOneWidget,
      );
      expect(find.text('Waiting for payment'), findsOneWidget);

      final fetchesBefore = wallet.fetchCount;
      wallet.pay(21000);
      await tester.pumpAndSettle();
      expect(find.text('Payment received'), findsOneWidget);
      expect(find.text('Into Savings'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Waiting for confirmation\nUsually within 2 minutes',
        ),
        findsOneWidget,
      );
      expect(haptics, ['HapticFeedbackType.successNotification']);

      wallet.confirm();
      await tester.pumpAndSettle();
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Waiting for confirmation'), findsNothing);
      expect(haptics, hasLength(1));
      expect(wallet.fetchCount, fetchesBefore + 2);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Total balance'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('an amount goes into the QR code and what is copied', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final wallet = FakeWallet.liquid('savings', 'Savings');
      await pumpLumen(tester, sources, wallets: [wallet]);
      await tester.tap(find.text('Receive'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Copy address'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add amount'));
      await tester.pumpAndSettle();
      expect(
        find.text('Optional. Leave it empty to receive any amount.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), '21000');
      await tester.tap(find.text('Show QR code'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(_liquidQr).label,
        'QR code of the Liquid address for 21,000 sats. The address is below, with a copy button.',
      );
      await tester.tap(find.byTooltip('Copy address'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit amount'));
      await tester.pumpAndSettle();
      expect(find.text('21000'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Add amount'), findsOneWidget);

      expect(copied, [
        liquidAddress,
        'liquidnetwork:$liquidAddress?amount=0.00021'
            '&assetid=6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d',
      ]);
      expect(wallet.addressCount, 1);
      handle.dispose();
    });

    testWidgets('a payment while the amount is edited still shows', (
      tester,
    ) async {
      final wallet = FakeWallet.liquid('savings', 'Savings');
      await pumpLumen(tester, sources, wallets: [wallet]);
      await tester.tap(find.text('Receive'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add amount'));
      await tester.pumpAndSettle();

      wallet.pay(500);
      await tester.pumpAndSettle();

      expect(find.text('Payment received'), findsOneWidget);
    });

    testWidgets('an address it cannot give says how to fix it', (tester) async {
      final wallet = FakeWallet.liquid('savings', 'Savings')
        ..receiveError = ReceiveError.unreachable;
      await pumpLumen(tester, sources, wallets: [wallet]);
      await tester.tap(find.text('Receive'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Lumen could not get an address from this wallet. Check your connection, then try again.',
        ),
        findsOneWidget,
      );
      wallet.receiveError = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(_liquidQr, findsOneWidget);
    });

    testWidgets('choosing a Lightning wallet asks for an amount again', (
      tester,
    ) async {
      final home = FakeWallet('home', 'Home node');
      final savings = FakeWallet.liquid('savings', 'Savings');
      await pumpLumen(tester, sources, wallets: [home, savings]);
      await tester.tap(find.text('Receive'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '300');
      await tester.tap(find.text('Create invoice'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home node').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Savings').last);
      await tester.pumpAndSettle();
      expect(_liquidQr, findsOneWidget);
      expect(_qr, findsNothing);

      await tester.tap(find.text('Savings').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home node').last);
      await tester.pumpAndSettle();
      expect(find.text('Create invoice'), findsOneWidget);
      expect(_liquidQr, findsNothing);
      expect(home.invoiceAmounts, [300]);
    });
  });

  testWidgets('on desktop, receive is a dialog that Escape closes', (
    tester,
  ) async {
    final wallet = FakeWallet('home', 'Home node');
    await pumpLumen(tester, sources, wallets: [wallet], size: desktopSize);

    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await createInvoice(tester, '21');
    expect(_qr, findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Overview'), findsWidgets);
  });
}

bool _focused(WidgetTester tester, Finder finder) {
  final focused = FocusManager.instance.primaryFocus?.context;
  return focused != null &&
      find
          .descendant(of: finder, matching: find.byWidget(focused.widget))
          .evaluate()
          .isNotEmpty;
}
