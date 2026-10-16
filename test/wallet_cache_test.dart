import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/wallets/wallet_cache.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('saved activity reads back the same', () async {
    final cache = SecureWalletCache();
    final at = DateTime.fromMillisecondsSinceEpoch(1760000000000);
    await cache.writeActivity('a', [
      Transaction(
        id: 'zap',
        direction: TransactionDirection.incoming,
        sats: 21000,
        at: at,
        description: 'Zap from bob',
      ),
      Transaction(
        id: 'coffee',
        direction: TransactionDirection.outgoing,
        sats: 5400,
        at: at,
      ),
    ]);

    final [zap, coffee] = (await SecureWalletCache().readActivity('a'))!;
    expect(
      (zap.id, zap.isIncoming, zap.sats, zap.at),
      ('zap', true, 21000, at),
    );
    expect(zap.description, 'Zap from bob');
    expect((coffee.isIncoming, coffee.description), (false, null));
  });

  test('a chain payment stays pending when read back', () async {
    final cache = SecureWalletCache();
    await cache.writeActivity('a', [
      Transaction(
        id: 'tx1',
        direction: TransactionDirection.incoming,
        sats: 5000,
        at: DateTime.fromMillisecondsSinceEpoch(1760000000000),
        txid: 'tx1',
        confirmations: 0,
      ),
    ]);

    final [saved] = (await SecureWalletCache().readActivity('a'))!;
    expect((saved.txid, saved.isPending), ('tx1', true));
  });

  test('unreadable activity counts as none saved', () async {
    FlutterSecureStorage.setMockInitialValues({'lumen.activity.a': '{bad'});

    expect(await SecureWalletCache().readActivity('a'), isNull);
  });

  test('delete forgets the balance and the activity', () async {
    final cache = SecureWalletCache();
    await cache.writeBalance('a', 10);
    await cache.writeActivity('a', const []);

    await cache.delete('a');

    expect(await cache.readBalance('a'), isNull);
    expect(await cache.readActivity('a'), isNull);
  });
}
