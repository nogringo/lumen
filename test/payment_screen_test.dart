import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'fakes.dart';

void main() {
  late WalletSources sources;

  setUpAll(() => sources = memorySources());
  tearDownAll(() => sources.dispose());

  FakeWallet wallet() => FakeWallet('home', 'Home node')
    ..transactions = [
      tx(
        'coffee',
        sats: 5400,
        minutesAgo: 30,
        description: 'Coffee',
        feeSats: 3,
        preimage: 'proof' * 8,
        invoice: 'lnbc54u1${'q' * 60}',
      ),
      tx('zap', sats: 21000, incoming: true, minutesAgo: 60, feeSats: 0),
    ];

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  testWidgets('a row opens the payment with everything Lumen knows', (
    tester,
  ) async {
    await pumpLumen(tester, sources, wallets: [wallet()]);

    await tester.tap(find.text('Coffee'));
    await settle(tester);

    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Payment sent'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Home node'), findsOneWidget);
    expect(find.text('Lightning'), findsOneWidget);
    expect(find.text('3 sats'), findsOneWidget);
    expect(find.byTooltip('Copy payment hash'), findsOneWidget);
    expect(find.byTooltip('Copy preimage'), findsOneWidget);
    expect(find.byTooltip('Copy invoice'), findsOneWidget);
    expect(find.byTooltip('Share receipt'), findsOneWidget);
    expect(find.text('Confirmations'), findsNothing);
    expect(find.textContaining('View on'), findsNothing);
  });

  testWidgets('a received payment shows no fee', (tester) async {
    await pumpLumen(tester, sources, wallets: [wallet()]);

    await tester.tap(find.text('Received'));
    await settle(tester);

    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('Fee paid'), findsNothing);
    expect(find.byTooltip('Copy preimage'), findsNothing);
  });

  testWidgets('copying the preimage is announced', (tester) async {
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
    await pumpLumen(tester, sources, wallets: [wallet()]);
    await tester.tap(find.text('Coffee'));
    await settle(tester);
    tester.takeAnnouncements();

    await tester.tap(find.byTooltip('Copy preimage'));
    await tester.pump();

    expect(copied, ['proof' * 8]);
    expect([
      for (final a in tester.takeAnnouncements()) a.message,
    ], contains('Preimage copied'));
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a row reads as a button and opens with Enter on desktop', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpLumen(tester, sources, wallets: [wallet()], size: desktopSize);

    final row = tester.getSemantics(find.text('Coffee'));
    expect(row.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    Focus.of(tester.element(find.text('Coffee'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);

    expect(find.text('Payment sent'), findsOneWidget);
    handle.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('a payment Lumen no longer has says so', (tester) async {
    await pumpLumen(tester, sources, wallets: [wallet()]);

    GoRouter.of(tester.element(find.text('Coffee')))
        .push('/payment/home/missing');
    await settle(tester);

    expect(find.text('Lumen no longer has this payment.'), findsOneWidget);
    expect(find.byTooltip('Share receipt'), findsNothing);
  });

  group('a Liquid payment', () {
    late _Launcher launcher;

    setUp(() => UrlLauncherPlatform.instance = launcher = _Launcher());

    Transaction sent({required int confirmations}) => tx(
      'c0ffee',
      sats: 5000,
      minutesAgo: 5,
      feeSats: 30,
      confirmations: confirmations,
    );

    Future<void> openSent(
      WidgetTester tester, {
      int saved = 0,
      int now = 0,
    }) async {
      final wallet = FakeWallet.liquid('savings', 'Savings')
        ..transactions = [sent(confirmations: saved)];
      await pumpLumen(tester, sources, wallets: [wallet]);
      wallet.transactions = [sent(confirmations: now)];
      await tester.tap(find.text('Sent'));
      await settle(tester);
    }

    testWidgets('a pending one says it waits for a block', (tester) async {
      await openSent(tester);

      expect(find.text('Waiting for confirmation'), findsOneWidget);
      expect(find.text('Confirmations'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('30 sats'), findsOneWidget);
      expect(find.byTooltip('Copy transaction ID'), findsOneWidget);
    });

    testWidgets('confirmations are read live, and announced once confirmed', (
      tester,
    ) async {
      await openSent(tester, now: 1204);

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('1,204'), findsOneWidget);
      expect([
        for (final a in tester.takeAnnouncements()) a.message,
      ], contains('Payment confirmed'));
    });

    testWidgets('the receipt names the transaction, without the link', (
      tester,
    ) async {
      String? shared;
      const share = MethodChannel('dev.fluttercommunity.plus/share');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(share, (
        call,
      ) async {
        shared = (call.arguments as Map)['text'] as String;
        return 'dev.fluttercommunity.plus/share/success';
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          share,
          null,
        ),
      );
      await openSent(tester, now: 3);

      await tester.tap(find.byTooltip('Share receipt'));
      await tester.pumpAndSettle();

      expect(shared, startsWith('Payment sent\n5,000 sats\nDate: '));
      expect(
        shared,
        endsWith(
          '\nNetwork: Liquid\nConfirmations: 3\nFee paid: 30 sats'
          '\nTransaction ID: c0ffee',
        ),
      );
      expect(shared, isNot(contains('Savings')));
    });

    testWidgets('the explorer opens with what unblinds the amounts', (
      tester,
    ) async {
      await openSent(tester);

      await tester.tap(find.text('View on liquid.network'));
      await tester.pump();

      expect(launcher.launched, [
        'https://liquid.network/tx/c0ffee#blinded=1,2',
      ]);
      expect(find.textContaining('could not open'), findsNothing);
    });

    testWidgets('an explorer that does not open says what to do instead', (
      tester,
    ) async {
      launcher.opens = false;
      await openSent(tester);
      tester.takeAnnouncements();

      await tester.tap(find.text('View on liquid.network'));
      await tester.pump();

      const message =
          'Lumen could not open liquid.network. Copy the transaction ID and '
          'look it up there.';
      expect(find.text(message), findsOneWidget);
      expect([
        for (final a in tester.takeAnnouncements()) a.message,
      ], contains(message));
    });
  });
}

class _Launcher extends UrlLauncherPlatform {
  final List<String> launched = [];
  bool opens = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return opens;
  }
}
