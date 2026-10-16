// ignore_for_file: experimental_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ndk/data_layer/repositories/wallets/mem_wallets_repo.dart';
import 'package:ndk/entities.dart' as ndk show NwcWallet;

import 'fakes.dart';

final _savedUri =
    'nostr+walletconnect://${'b' * 64}?relay=wss://relay.example.com&secret=${'c' * 64}';
const _duplicate = 'This wallet is already in Lumen.';

void main() {
  late WalletSources sources;

  setUpAll(() async {
    final repo = MemWalletsRepo();
    await repo.storeWallet(
      ndk.NwcWallet(
        id: 'saved',
        name: 'Home node',
        supportedUnits: const {'sat'},
        nwcUrl: _savedUri,
      ),
    );
    sources = memorySources(repo: repo);
  });
  tearDownAll(() => sources.dispose());

  Future<void> openConnect(WidgetTester tester) async {
    await pumpLumen(tester, sources, wallets: []);
    await tester.tap(find.text('Add a wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lightning wallet'));
    await tester.pumpAndSettle();
  }

  testWidgets('a saved connection is flagged as soon as it is entered', (
    tester,
  ) async {
    await openConnect(tester);

    await tester.enterText(find.byType(TextField).first, _savedUri);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text(_duplicate), findsOneWidget);
    expect(tester.takeAnnouncements().map((a) => a.message), [_duplicate]);
  });

  testWidgets('connect reports a saved connection before a missing name', (
    tester,
  ) async {
    await openConnect(tester);
    await tester.enterText(find.byType(TextField).first, _savedUri);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Connect'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.text(_duplicate), findsOneWidget);
    expect(find.text('Give this wallet a name.'), findsNothing);
  });
}
