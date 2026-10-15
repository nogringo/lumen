// ignore_for_file: experimental_member_use

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ndk/data_layer/repositories/wallets/mem_wallets_repo.dart';
import 'package:ndk/entities.dart' as ndk show NwcWallet;

import 'fakes.dart';

const _scanner = MethodChannel('lumen/scanner');

final _savedUri =
    'nostr+walletconnect://${'b' * 64}?relay=wss://relay.example.com&secret=${'c' * 64}';

void main() {
  late WalletSources sources;

  setUpAll(() async {
    final repo = MemWalletsRepo();
    await repo.storeWallet(
      ndk.NwcWallet(
        id: 'saved',
        name: 'Saved node',
        supportedUnits: const {'sat'},
        nwcUrl: _savedUri,
      ),
    );
    sources = memorySources(repo: repo);
  });
  tearDownAll(() => sources.dispose());

  /// The camera reads [text], or is closed when it is null. Returns the
  /// strings each scan was opened with.
  List<Map<Object?, Object?>> scanReturns(WidgetTester tester, String? text) {
    final opened = <Map<Object?, Object?>>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_scanner, (
      call,
    ) async {
      opened.add(call.arguments as Map<Object?, Object?>);
      return text;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        _scanner,
        null,
      ),
    );
    return opened;
  }

  Future<void> pumpHome(WidgetTester tester, {Size size = phoneSize}) =>
      pumpLumen(
        tester,
        sources,
        wallets: [FakeWallet('home', 'Home node', balance: 1000)],
        size: size,
      );

  Future<void> tapScan(WidgetTester tester) async {
    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
  }

  testWidgets('Scan on Home opens Send with the scanned invoice', (
    tester,
  ) async {
    final opened = scanReturns(
      tester,
      'lightning:${fakeBolt11(21, description: 'Tip')}',
    );
    await pumpHome(tester);

    await tapScan(tester);

    expect(opened.single['title'], 'Scan a QR code');
    expect(find.text('Amount set by the invoice'), findsOneWidget);
    expect(find.text('Tip'), findsOneWidget);
    expect(
      tester.takeAnnouncements().map((a) => a.message),
      contains('Lightning invoice, 21 sats'),
    );
  });

  testWidgets('Scan on Home opens Connect with a scanned connection', (
    tester,
  ) async {
    scanReturns(tester, _savedUri);
    await pumpHome(tester);

    await tapScan(tester);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text('Connect with NWC'), findsWidgets);
    expect(find.text(_savedUri), findsOneWidget);
    expect(find.text('This wallet is already in Lumen.'), findsOneWidget);
  });

  testWidgets('a scanned code Lumen cannot pay is flagged at once', (
    tester,
  ) async {
    scanReturns(tester, 'https://example.com');
    await pumpHome(tester);
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    await tapScan(tester);

    const error =
        'This is not a Lightning invoice or address. An invoice starts with lnbc, an address looks like name@example.com.';
    expect(find.text(error), findsOneWidget);
    expect(tester.takeAnnouncements().map((a) => a.message), contains(error));
  });

  testWidgets('closing the camera leaves Send as it was', (tester) async {
    scanReturns(tester, null);
    await pumpHome(tester);
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    await tapScan(tester);

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
  });

  testWidgets('Scan is announced as Scan a QR code', (tester) async {
    await pumpHome(tester);

    expect(find.bySemanticsLabel('Scan a QR code'), findsOneWidget);
  });

  testWidgets('desktop apps have no Scan yet', (tester) async {
    await pumpHome(tester, size: desktopSize);

    expect(find.text('Scan'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
