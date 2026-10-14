import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'lock_store.dart';

/// Secure storage that seals each value with the App lock data key while one
/// is set, so the platform store alone no longer reveals the wallets.
///
/// Values written while App lock was off stay readable as they are, so data
/// left half sealed by an interruption still loads.
class SealedStorage extends FlutterSecureStorage {
  SealedStorage();

  /// The App lock record has to be read before anything can be opened.
  static const _unsealed = {SecureLockStore.storageKey};

  SecretKey? dataKey;

  static const _tag = 'sealed:';
  static final _cipher = AesGcm.with256bits();

  /// Seals every value under [key], and every value written from now on.
  Future<void> sealAll(SecretKey key) async {
    dataKey = key;
    for (final MapEntry(key: name, value: stored)
        in (await super.readAll()).entries) {
      if (_unsealed.contains(name) || stored.startsWith(_tag)) continue;
      await super.write(key: name, value: await _seal(name, stored, key));
    }
  }

  /// Turns every value sealed under [key] back into plain text.
  Future<void> unsealAll(SecretKey key) async {
    dataKey = null;
    for (final MapEntry(key: name, value: stored)
        in (await super.readAll()).entries) {
      if (!stored.startsWith(_tag)) continue;
      await super.write(key: name, value: await _open(name, stored, key));
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final stored = await super.read(
      key: key,
      iOptions: iOptions,
      aOptions: aOptions,
      lOptions: lOptions,
      webOptions: webOptions,
      mOptions: mOptions,
      wOptions: wOptions,
    );
    return stored == null ? null : _open(key, stored, dataKey);
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final all = await super.readAll(
      iOptions: iOptions,
      aOptions: aOptions,
      lOptions: lOptions,
      webOptions: webOptions,
      mOptions: mOptions,
      wOptions: wOptions,
    );
    return {
      for (final MapEntry(:key, :value) in all.entries)
        key: await _open(key, value, dataKey),
    };
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final sealWith = _unsealed.contains(key) ? null : dataKey;
    return super.write(
      key: key,
      value: value == null || sealWith == null
          ? value
          : await _seal(key, value, sealWith),
      iOptions: iOptions,
      aOptions: aOptions,
      lOptions: lOptions,
      webOptions: webOptions,
      mOptions: mOptions,
      wOptions: wOptions,
    );
  }

  /// The storage key goes in as associated data, so a sealed value cannot be
  /// moved under another key.
  static Future<String> _seal(String name, String value, SecretKey key) async {
    final box = await _cipher.encrypt(
      utf8.encode(value),
      secretKey: key,
      aad: utf8.encode(name),
    );
    return '$_tag${base64.encode(box.concatenation())}';
  }

  static Future<String> _open(
    String name,
    String stored,
    SecretKey? key,
  ) async {
    if (!stored.startsWith(_tag)) return stored;
    if (key == null) throw StateError('$name is sealed and Lumen is locked');
    final box = SecretBox.fromConcatenation(
      base64.decode(stored.substring(_tag.length)),
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    return utf8.decode(
      await _cipher.decrypt(box, secretKey: key, aad: utf8.encode(name)),
    );
  }
}
