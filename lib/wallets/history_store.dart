import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:sembast/sembast.dart' hide Transaction;
import 'package:sembast/sembast_memory.dart' show newDatabaseFactoryMemory;

import 'history_database_io.dart'
    if (dart.library.js_interop) 'history_database_web.dart';

/// How far Lumen has walked a wallet's list of transactions, from the newest.
@immutable
class HistorySync {
  const HistorySync({this.offset = 0, this.complete = false});

  /// Entries walked so far. The next older page starts there.
  final int offset;

  /// Whether the walk reached the oldest transaction.
  final bool complete;

  bool get started => offset > 0 || complete;
}

typedef SavedTransaction = ({String walletId, Transaction transaction});

/// Every transaction Lumen has seen, kept on the device so it stays readable
/// offline.
class HistoryStore {
  HistoryStore(this._db);

  final Database _db;

  static final _transactions = stringMapStoreFactory.store('transactions');
  static final _syncs = stringMapStoreFactory.store('sync');

  static const keyName = 'lumen.history.key';

  /// Raised when records gain fields, so every wallet walks its list again.
  static const _format = 2;

  /// Opens the history on disk, or in IndexedDB on the web. Its key lives in
  /// [storage], so App lock seals it with the wallets. A history the key no
  /// longer opens, as after a reset, starts again empty.
  static Future<HistoryStore> open(
    FlutterSecureStorage storage, {
    DatabaseFactory? factory,
    String? path,
  }) async {
    final (dbFactory, location) = factory != null && path != null
        ? (factory, path)
        : await historyDatabase();
    final codec = SembastCodec(
      signature: 'lumen-aes-gcm',
      codec: _SealedCodec(await _key(storage)),
    );
    try {
      return HistoryStore(await dbFactory.openDatabase(location, codec: codec));
    } on DatabaseException catch (e) {
      if (e.code != DatabaseException.errInvalidCodec) rethrow;
      await dbFactory.deleteDatabase(location);
      return HistoryStore(await dbFactory.openDatabase(location, codec: codec));
    }
  }

  /// A history that lasts until it is closed.
  static Future<HistoryStore> memory() async =>
      HistoryStore(await newDatabaseFactoryMemory().openDatabase('history'));

  static Future<SecretKey> _key(FlutterSecureStorage storage) async {
    final saved = await storage.read(key: keyName);
    if (saved != null) return SecretKey(base64.decode(saved));
    final key = await _SealedCodec._cipher.newSecretKey();
    await storage.write(
      key: keyName,
      value: base64.encode(await key.extractBytes()),
    );
    return key;
  }

  /// Saves [transactions] of [walletId], replacing those with the same id.
  /// Returns how many were not saved yet.
  Future<int> save(String walletId, List<Transaction> transactions) {
    if (transactions.isEmpty) return Future.value(0);
    final records = _transactions.records([
      for (final t in transactions) _recordKey(walletId, t.id),
    ]);
    return _db.transaction((txn) async {
      final known = await records.get(txn);
      await records.put(txn, [
        for (final t in transactions) _encode(walletId, t),
      ]);
      return known.where((value) => value == null).length;
    });
  }

  /// The saved transactions of [walletIds], newest first.
  Future<List<SavedTransaction>> read(
    Set<String> walletIds, {
    int offset = 0,
    required int limit,
  }) async {
    final found = await _transactions.find(
      _db,
      finder: Finder(
        filter: Filter.inList('wallet', walletIds.toList()),
        sortOrders: [SortOrder('at', false), SortOrder(Field.key, false)],
        offset: offset,
        limit: limit,
      ),
    );
    return [for (final record in found) _decode(record.value)];
  }

  /// The saved transaction [id] of [walletId], or null.
  Future<Transaction?> find(String walletId, String id) async {
    final value = await _transactions.record(_recordKey(walletId, id)).get(_db);
    return value == null ? null : _decode(value).transaction;
  }

  Future<HistorySync> readSync(String walletId) async {
    final saved = await _syncs.record(walletId).get(_db);
    if (saved == null || saved['format'] != _format) return const HistorySync();
    return HistorySync(
      offset: saved['offset'] as int,
      complete: saved['complete'] as bool,
    );
  }

  Future<void> writeSync(String walletId, HistorySync sync) =>
      _syncs.record(walletId).put(_db, {
        'offset': sync.offset,
        'complete': sync.complete,
        'format': _format,
      });

  /// Forgets everything saved for [walletId].
  Future<void> delete(String walletId) => _db.transaction((txn) async {
    await _transactions.delete(
      txn,
      finder: Finder(filter: Filter.equals('wallet', walletId)),
    );
    await _syncs.record(walletId).delete(txn);
  });

  Future<void> close() => _db.close();

  static String _recordKey(String walletId, String id) => '$walletId/$id';

  static Map<String, Object?> _encode(String walletId, Transaction t) => {
    'wallet': walletId,
    'id': t.id,
    'incoming': t.isIncoming,
    'sats': t.sats,
    'at': t.at.millisecondsSinceEpoch,
    'description': t.description,
    'paymentHash': t.paymentHash,
    'feeSats': t.feeSats,
    'preimage': t.preimage,
    'invoice': t.invoice,
    'txid': t.txid,
    'confirmations': t.confirmations,
  };

  static SavedTransaction _decode(Map<String, Object?> json) => (
    walletId: json['wallet'] as String,
    transaction: Transaction(
      id: json['id'] as String,
      direction: json['incoming'] as bool
          ? TransactionDirection.incoming
          : TransactionDirection.outgoing,
      sats: json['sats'] as int,
      at: DateTime.fromMillisecondsSinceEpoch(json['at'] as int),
      description: json['description'] as String?,
      paymentHash: json['paymentHash'] as String?,
      feeSats: json['feeSats'] as int?,
      preimage: json['preimage'] as String?,
      invoice: json['invoice'] as String?,
      txid: json['txid'] as String?,
      confirmations: json['confirmations'] as int?,
    ),
  );
}

/// Seals each record with AES-256-GCM, so the file or IndexedDB alone shows
/// no payment.
final class _SealedCodec extends AsyncContentCodecBase {
  _SealedCodec(this._key);

  final SecretKey _key;

  static final _cipher = AesGcm.with256bits();

  @override
  Future<String> encodeAsync(Object? input) async {
    final box = await _cipher.encrypt(
      utf8.encode(jsonEncode(input)),
      secretKey: _key,
    );
    return base64.encode(box.concatenation());
  }

  @override
  Future<Object?> decodeAsync(String encoded) async {
    final box = SecretBox.fromConcatenation(
      base64.decode(encoded),
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    return jsonDecode(utf8.decode(await _cipher.decrypt(box, secretKey: _key)));
  }
}
