import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/wallets/history_store.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:sembast/sembast_io.dart' show databaseFactoryIo;

import 'fakes.dart';

void main() {
  late Directory dir;
  late String path;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('lumen_history');
    path = '${dir.path}/history.db';
  });

  tearDown(() => dir.delete(recursive: true));

  Future<HistoryStore> open() => HistoryStore.open(
    const FlutterSecureStorage(),
    factory: databaseFactoryIo,
    path: path,
  );

  test('reads transactions back newest first, across wallets', () async {
    final history = await HistoryStore.memory();
    addTearDown(history.close);

    expect(await history.save('a', [tx('a1', minutesAgo: 30), tx('a2')]), 2);
    expect(await history.save('b', [tx('b1', minutesAgo: 10)]), 1);
    expect(await history.save('a', [tx('a2'), tx('a3', minutesAgo: 50)]), 1);

    final all = await history.read({'a', 'b'}, limit: 10);
    expect([for (final s in all) s.transaction.id], ['a2', 'b1', 'a1', 'a3']);
    expect(all[1].walletId, 'b');

    final page = await history.read({'a'}, offset: 1, limit: 1);
    expect(page.single.transaction.id, 'a1');
  });

  test('transactions are sealed on disk and open again', () async {
    final history = await open();
    await history.save('a', [
      Transaction(
        id: 'hash1',
        direction: TransactionDirection.outgoing,
        sats: 5400,
        at: DateTime(2026, 10, 15, 9, 30),
        description: 'Coffee at Mia',
        paymentHash: 'hash1',
        feeSats: 3,
        preimage: 'proof',
        invoice: 'lnbc54u1',
      ),
    ]);
    await history.writeSync('a', const HistorySync(offset: 25));
    await history.close();

    final raw = await File(path).readAsString();
    expect(raw, isNot(contains('Coffee')));
    expect(raw, isNot(contains('hash1')));

    final reopened = await open();
    addTearDown(reopened.close);
    final saved = (await reopened.find('a', 'hash1'))!;
    expect(saved.description, 'Coffee at Mia');
    expect(saved.at, DateTime(2026, 10, 15, 9, 30));
    expect(
      (saved.paymentHash, saved.feeSats, saved.preimage, saved.invoice),
      ('hash1', 3, 'proof', 'lnbc54u1'),
    );
    expect(await reopened.find('a', 'other'), isNull);
    expect((await reopened.readSync('a')).offset, 25);
  });

  test('a chain payment keeps its txid and confirmations', () async {
    final history = await HistoryStore.memory();
    addTearDown(history.close);
    await history.save('liquid', [
      Transaction(
        id: 'tx1',
        direction: TransactionDirection.incoming,
        sats: 25000,
        at: DateTime(2026, 10, 16, 14),
        txid: 'tx1',
        confirmations: 0,
      ),
    ]);

    final saved = (await history.find('liquid', 'tx1'))!;
    expect((saved.txid, saved.confirmations), ('tx1', 0));
    expect(saved.isPending, isTrue);
  });

  test('a history its key no longer opens starts again empty', () async {
    final history = await open();
    await history.save('a', [tx('hash1')]);
    await history.close();

    await const FlutterSecureStorage().delete(key: HistoryStore.keyName);

    final reopened = await open();
    addTearDown(reopened.close);
    expect(await reopened.read({'a'}, limit: 10), isEmpty);
  });

  test('delete forgets a wallet and how far it was walked', () async {
    final history = await HistoryStore.memory();
    addTearDown(history.close);
    await history.save('a', [tx('a1')]);
    await history.save('b', [tx('b1')]);
    await history.writeSync('a', const HistorySync(complete: true));

    await history.delete('a');

    expect(await history.read({'a', 'b'}, limit: 10), hasLength(1));
    expect((await history.readSync('a')).started, isFalse);
  });
}
