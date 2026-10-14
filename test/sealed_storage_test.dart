import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/lock/lock_store.dart';
import 'package:lumen/lock/sealed_storage.dart';
import 'package:ndk/entities.dart' as ndk;
import 'package:ndk_flutter/ndk_flutter.dart';

void main() {
  const uri = 'nostr+walletconnect://abc?relay=wss://relay.example&secret=123';
  late SecretKey key;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    key = await AesGcm.with256bits().newSecretKey();
  });

  Future<Map<String, String>> raw() => const FlutterSecureStorage().readAll();

  test('values stay plain while no key is set', () async {
    await SealedStorage().write(key: 'a', value: 'balance');

    expect(await raw(), {'a': 'balance'});
  });

  test('sealing hides every value but the App lock record', () async {
    await const FlutterSecureStorage().write(key: 'a', value: 'balance');
    await const FlutterSecureStorage().write(
      key: SecureLockStore.storageKey,
      value: 'record',
    );
    final storage = SealedStorage();

    await storage.sealAll(key);
    await storage.write(key: 'b', value: 'activity');

    final stored = await raw();
    expect(stored[SecureLockStore.storageKey], 'record');
    expect(stored['a'], allOf(startsWith('sealed:'), isNot(contains('bal'))));
    expect(stored['b'], allOf(startsWith('sealed:'), isNot(contains('act'))));
    expect(await storage.read(key: 'a'), 'balance');
    expect(await storage.read(key: 'b'), 'activity');
  });

  test('a sealed value cannot be read without the key', () async {
    await (SealedStorage()..dataKey = key).write(key: 'a', value: 'balance');

    await expectLater(SealedStorage().read(key: 'a'), throwsStateError);
  });

  test('a sealed value moved under another key does not open', () async {
    await (SealedStorage()..dataKey = key).write(key: 'a', value: 'balance');
    final sealed = (await raw())['a']!;
    await const FlutterSecureStorage().write(key: 'b', value: sealed);

    await expectLater(
      (SealedStorage()..dataKey = key).read(key: 'b'),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('unsealing turns the values back into plain text', () async {
    final storage = SealedStorage();
    await storage.sealAll(key);
    await storage.write(key: 'a', value: 'balance');

    await storage.unsealAll(key);
    await storage.write(key: 'b', value: 'activity');

    expect(await raw(), {'a': 'balance', 'b': 'activity'});
  });

  test('NWC connection strings are sealed in the ndk wallets store', () async {
    final storage = SealedStorage()..dataKey = key;
    await FlutterSecureStorageWalletsRepo(storage: storage).storeWallet(
      ndk.NwcWallet.fromStorage(
        id: 'home',
        name: 'Home node',
        supportedUnits: {'sat'},
        metadata: {'nwcUrl': uri},
      ),
    );

    expect((await raw()).values.join(), isNot(contains('secret=123')));

    final reopened = FlutterSecureStorageWalletsRepo(
      storage: SealedStorage()..dataKey = key,
    );
    final [wallet as ndk.NwcWallet] = await reopened.getWallets();
    expect((wallet.name, wallet.nwcUrl), ('Home node', uri));
  });
}
