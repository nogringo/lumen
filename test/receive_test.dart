import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

final _qr = find.bySemanticsLabel(RegExp(r'^QR code of the Lightning invoice'));

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

    final fetchesBefore = wallet.fetchCount;
    wallet.balance = 21100;
    wallet.pay();
    await tester.pumpAndSettle();
    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('Into Home node'), findsOneWidget);
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
