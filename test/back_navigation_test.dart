import 'package:flutter/gestures.dart';
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

  FakeWallet wallet() =>
      FakeWallet('home', 'Home node')
        ..transactions = [tx('coffee', sats: 5400, description: 'Coffee')];

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> openPayment(WidgetTester tester) async {
    await pumpLumen(tester, sources, wallets: [wallet()], size: desktopSize);
    await tester.tap(find.text('Coffee'));
    await settle(tester);
    expect(find.text('Payment sent'), findsOneWidget);
  }

  Future<void> press(
    WidgetTester tester,
    LogicalKeyboardKey modifier,
    LogicalKeyboardKey key,
  ) async {
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(modifier);
  }

  testWidgets('a payment has a back button on desktop', (tester) async {
    await openPayment(tester);

    await tester.tap(find.byTooltip('Back'));
    await settle(tester);

    expect(find.text('Payment sent'), findsNothing);
    expect(find.text('Coffee'), findsOneWidget);
  });

  testWidgets('the back button names its keys on a desktop platform', (
    tester,
  ) async {
    await openPayment(tester);

    expect(find.byTooltip('Back (⌘←)'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  for (final (name, modifier, key) in [
    ('⌘[', LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.bracketLeft),
    ('⌘←', LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.arrowLeft),
    ('Alt+←', LogicalKeyboardKey.altLeft, LogicalKeyboardKey.arrowLeft),
  ]) {
    testWidgets('$name goes back', (tester) async {
      await openPayment(tester);

      await press(tester, modifier, key);
      await settle(tester);

      expect(find.text('Payment sent'), findsNothing);
    });
  }

  testWidgets("the mouse's back button goes back", (tester) async {
    await openPayment(tester);

    final click = await tester.startGesture(
      tester.getCenter(find.text('Payment sent')),
      kind: PointerDeviceKind.mouse,
      buttons: kBackMouseButton,
    );
    await click.up();
    await settle(tester);

    expect(find.text('Payment sent'), findsNothing);
  });

  testWidgets('a text field keeps Alt+← for its cursor', (tester) async {
    await pumpLumen(tester, sources, wallets: [wallet()], size: desktopSize);
    GoRouter.of(tester.element(find.text('Coffee'))).push('/connect');
    await settle(tester);
    final field = find.byType(TextField).first;
    await tester.enterText(field, 'nostr+walletconnect://');

    await press(
      tester,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.arrowLeft,
    );
    await settle(tester);

    expect(find.text('Connect with NWC'), findsOneWidget);
    final controller = tester.widget<TextField>(field).controller!;
    expect(controller.selection, const TextSelection.collapsed(offset: 0));
  });
}
