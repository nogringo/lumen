import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

/// Barista's Lightning address accepts up to [_maxSats].
const _maxSats = 1000000;

void main() {
  late WalletSources sources;
  final asked = <int>[];

  setUpAll(() {
    sources = memorySources(
      httpClient: MockClient((request) async {
        final url = request.url;
        if (url.path == '/.well-known/lnurlp/barista') {
          return http.Response(
            jsonEncode({
              'tag': 'payRequest',
              'callback': 'https://example.com/lnurlp/barista/callback',
              'minSendable': 1000,
              'maxSendable': _maxSats * 1000,
              'metadata': '[["text/plain","Barista"]]',
            }),
            200,
          );
        }
        if (url.path == '/lnurlp/barista/callback') {
          final sats = int.parse(url.queryParameters['amount']!) ~/ 1000;
          asked.add(sats);
          return http.Response(jsonEncode({'pr': fakeBolt11(sats)}), 200);
        }
        return http.Response(
          jsonEncode({'status': 'ERROR', 'reason': 'Not found'}),
          404,
        );
      }),
    );
  });
  tearDownAll(() => sources.dispose());
  setUp(asked.clear);

  Future<void> openSend(WidgetTester tester) async {
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
  }

  Future<void> fillTo(WidgetTester tester, String to) async {
    await tester.enterText(find.byType(TextField).first, to);
    await tester.pump();
  }

  Future<void> review(WidgetTester tester) async {
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
  }

  testWidgets('pays a pasted invoice on a phone', (tester) async {
    final handle = tester.ensureSemantics();
    final haptics = watchHaptics(tester);
    final wallet = FakeWallet('home', 'Home node', balance: 152300)
      ..feeSats = 3;
    await pumpLumen(tester, sources, wallets: [wallet]);

    await openSend(tester);
    expect(find.text('Pay from'), findsOneWidget);
    await fillTo(tester, fakeBolt11(5400, description: 'Coffee'));
    expect(find.text('Amount set by the invoice'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Amount in sats'), findsNothing);

    await review(tester);
    expect(find.text('You are sending'), findsOneWidget);
    expect(find.text('Lightning'), findsOneWidget);
    expect(find.bySemanticsLabel('To\nLightning invoice'), findsOneWidget);

    final fetchesBefore = wallet.fetchCount;
    await tester.tap(find.text('Send 5,400 sats'));
    await tester.pumpAndSettle();
    expect(wallet.paid.single.sats, 5400);
    expect(find.text('Payment sent'), findsOneWidget);
    expect(haptics, ['HapticFeedbackType.successNotification']);
    expect(find.text('3 sats'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    final hash = _fakeHash(5400);
    expect(
      find.text('${hash.substring(0, 4)}...${hash.substring(60)}'),
      findsOneWidget,
    );
    expect(wallet.fetchCount, fetchesBefore + 1);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Total balance'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the receipt can be shared and its hash copied', (tester) async {
    String? shared;
    String? copied;
    final messenger = tester.binding.defaultBinaryMessenger;
    const share = MethodChannel('dev.fluttercommunity.plus/share');
    messenger.setMockMethodCallHandler(share, (call) async {
      shared = (call.arguments as Map)['text'] as String;
      return 'dev.fluttercommunity.plus/share/success';
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(share, null);
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });
    final wallet = FakeWallet('home', 'Home node', balance: 10000)..feeSats = 1;
    await pumpLumen(tester, sources, wallets: [wallet]);
    await openSend(tester);
    await fillTo(tester, 'barista@example.com');
    await tester.enterText(find.byType(TextField).last, '2100');
    await review(tester);
    await tester.tap(find.text('Send 2,100 sats'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Copy payment hash'));
    await tester.pumpAndSettle();
    expect(copied, _fakeHash(2100));

    await tester.tap(find.byTooltip('Share receipt'));
    await tester.pumpAndSettle();
    expect(
      shared,
      startsWith('Payment sent\n2,100 sats\nTo barista@example.com\nDate: '),
    );
    expect(shared, contains('\nFee paid: 1 sats\n'));
    expect(shared, contains('\nPayment hash: ${_fakeHash(2100)}\n'));
    expect(shared, endsWith('\nPreimage: preimage'));
    expect(shared, isNot(contains('Home node')));
  });

  testWidgets('pays a Lightning address the amount typed', (tester) async {
    final wallet = FakeWallet('home', 'Home node', balance: 152300);
    await pumpLumen(tester, sources, wallets: [wallet]);
    await openSend(tester);

    await fillTo(tester, 'barista@example.com');
    await tester.enterText(find.byType(TextField).last, '2100');
    await review(tester);
    expect(find.text('barista@example.com'), findsOneWidget);
    expect(asked, isEmpty);

    await tester.tap(find.text('Send 2,100 sats'));
    await tester.pumpAndSettle();
    expect(asked, [2100]);
    expect(wallet.paid.single.sats, 2100);
    expect(find.text('To barista@example.com'), findsOneWidget);
  });

  testWidgets('an amount the address does not accept says the range', (
    tester,
  ) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [FakeWallet('home', 'Home node', balance: 99000000)],
    );
    await openSend(tester);

    await fillTo(tester, 'barista@example.com');
    await tester.enterText(find.byType(TextField).last, '${_maxSats + 1}');
    await review(tester);

    expect(
      find.text('barista@example.com accepts from 1 to 1,000,000 sats.'),
      findsOneWidget,
    );
    expect(find.text('You are sending'), findsNothing);
  });

  testWidgets('an unknown address says to check it', (tester) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [FakeWallet('home', 'Home node', balance: 1000)],
    );
    await openSend(tester);

    await fillTo(tester, 'nobody@example.com');
    await tester.enterText(find.byType(TextField).last, '21');
    await review(tester);

    expect(
      find.text(
        'nobody@example.com cannot receive payments right now. Check the address with the recipient.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('what cannot be paid says how to fix it', (tester) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [FakeWallet('home', 'Home node', balance: 1000)],
    );
    await openSend(tester);

    await review(tester);
    expect(
      find.text('Paste a Lightning invoice or a Lightning address.'),
      findsOneWidget,
    );

    await fillTo(tester, 'hello');
    await review(tester);
    expect(
      find.text(
        'This is not a Lightning invoice or address. An invoice starts with lnbc, an address looks like name@example.com.',
      ),
      findsOneWidget,
    );

    await fillTo(tester, fakeBolt11(null));
    await review(tester);
    expect(
      find.text(
        'This invoice leaves the amount open, which Lumen cannot pay yet. Ask the recipient for an invoice with an amount.',
      ),
      findsOneWidget,
    );

    await fillTo(
      tester,
      fakeBolt11(
        100,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    );
    await review(tester);
    expect(
      find.text('This invoice expired. Ask the recipient for a new one.'),
      findsOneWidget,
    );

    await fillTo(tester, 'barista@example.com');
    await review(tester);
    expect(find.text('Enter an amount of at least 1 sat.'), findsOneWidget);
    expect(find.text('You are sending'), findsNothing);
  });

  testWidgets('a wallet that holds too little is caught before review', (
    tester,
  ) async {
    final wallet = FakeWallet('home', 'Home node', balance: 100);
    await pumpLumen(tester, sources, wallets: [wallet]);
    await openSend(tester);

    await fillTo(tester, fakeBolt11(5400));
    await review(tester);

    expect(
      find.text(
        'Home node holds 100 sats, not enough for this payment. Pay from another wallet or lower the amount.',
      ),
      findsOneWidget,
    );
    expect(wallet.paid, isEmpty);
  });

  testWidgets('Lumen picks a wallet that can pay', (tester) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [
        FakeWallet('home', 'Home node', balance: 100),
        FakeWallet('phone', 'Phone wallet', balance: 10000),
      ],
    );
    await openSend(tester);

    await fillTo(tester, fakeBolt11(5000));
    await review(tester);

    expect(find.text('Phone wallet'), findsOneWidget);
    expect(find.text('Home node'), findsNothing);
  });

  testWidgets('a wallet screen preselects its wallet', (tester) async {
    final home = FakeWallet('home', 'Home node', balance: 10000);
    final phone = FakeWallet('phone', 'Phone wallet', balance: 10000);
    await pumpLumen(tester, sources, wallets: [home, phone]);

    await tester.tap(find.text('Phone wallet'));
    await tester.pumpAndSettle();
    await openSend(tester);
    await fillTo(tester, fakeBolt11(700));
    await review(tester);
    await tester.tap(find.text('Send 700 sats'));
    await tester.pumpAndSettle();

    expect(phone.paid, hasLength(1));
    expect(home.paid, isEmpty);
  });

  testWidgets('a failed payment can be retried from another wallet', (
    tester,
  ) async {
    final haptics = watchHaptics(tester);
    final home = FakeWallet('home', 'Home node', balance: 10000)
      ..sendError = SendError.insufficientBalance;
    final phone = FakeWallet('phone', 'Phone wallet', balance: 5000);
    await pumpLumen(tester, sources, wallets: [home, phone]);
    await openSend(tester);

    await fillTo(tester, fakeBolt11(4000));
    await review(tester);
    await tester.tap(find.text('Send 4,000 sats'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Home node does not hold enough sats for this payment and its fee. Pay from another wallet or lower the amount.',
      ),
      findsOneWidget,
    );
    expect(haptics, ['HapticFeedbackType.errorNotification']);

    await tester.tap(find.text('Edit payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pay from'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phone wallet').last);
    await tester.pumpAndSettle();
    await review(tester);
    await tester.tap(find.text('Send 4,000 sats'));
    await tester.pumpAndSettle();

    expect(phone.paid, hasLength(1));
    expect(find.text('Payment sent'), findsOneWidget);
  });

  testWidgets('an unconfirmed payment offers no retry', (tester) async {
    final haptics = watchHaptics(tester);
    final wallet = FakeWallet('home', 'Home node', balance: 10000)
      ..sendError = SendError.unconfirmed;
    await pumpLumen(tester, sources, wallets: [wallet]);
    await openSend(tester);

    await fillTo(tester, fakeBolt11(4000));
    await review(tester);
    await tester.tap(find.text('Send 4,000 sats'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Home node did not confirm the payment in time. It may still go through: check its recent activity before you try again.',
      ),
      findsOneWidget,
    );
    expect(haptics, ['HapticFeedbackType.warningNotification']);
    expect(find.text('Send 4,000 sats'), findsNothing);
    expect(find.text('Edit payment'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('Paste fills in the invoice', (tester) async {
    final invoice = fakeBolt11(21, description: 'Tip');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async =>
          call.method == 'Clipboard.getData' ? {'text': invoice} : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpLumen(
      tester,
      sources,
      wallets: [FakeWallet('home', 'Home node', balance: 1000)],
    );
    await openSend(tester);

    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();

    expect(find.text('Tip'), findsOneWidget);
    expect(find.text('Amount set by the invoice'), findsOneWidget);
  });

  testWidgets('on desktop, send is a dialog that stays open while paying', (
    tester,
  ) async {
    final wallet = FakeWallet('home', 'Home node', balance: 10000)
      ..paymentGate = Completer<void>();
    await pumpLumen(tester, sources, wallets: [wallet], size: desktopSize);

    await openSend(tester);
    expect(find.byType(Dialog), findsOneWidget);
    await fillTo(tester, fakeBolt11(21));
    await review(tester);
    await tester.tap(find.text('Send 21 sats'));
    await tester.pump();
    expect(find.text('Sending'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);

    wallet.paymentGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Payment sent'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}

/// The payment hash [fakeBolt11] puts in an invoice for [sats].
String _fakeHash(int sats) => [
  for (var i = 0; i < 32; i++)
    ((sats + i) % 256).toRadixString(16).padLeft(2, '0'),
].join();
