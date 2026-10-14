import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

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
}
