import 'package:crypto/crypto.dart';

import '../wallet.dart';

/// Reads a Liquid address, confidential or not, checking its checksum and
/// shape as Elements does. Returns null when [text] is not one.
ChainAddress? liquidAddress(String text) =>
    _segwitAddress(text) ?? _base58Address(text);

/// The L-BTC asset id on each network.
const lbtcAssetIds = {
  ChainNetwork.liquid:
      '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d',
  ChainNetwork.liquidTestnet:
      '144c654344aa716d6f3abcc1ca90e5641e4e2a7f633bc09fe3baf64585819a49',
};

const _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

/// Bech32 for unconfidential addresses, blech32 for confidential ones. Each
/// has a plain variant for witness version 0 and an "m" one above.
final class _Checksum {
  // Hex strings: blech32's 60-bit constants do not fit a web int.
  _Checksum(this.length, List<String> generators, String plain, String modified)
    : _generators = [for (final g in generators) BigInt.parse(g, radix: 16)],
      _plain = BigInt.parse(plain, radix: 16),
      _modified = BigInt.parse(modified, radix: 16),
      _shift = 5 * (length - 1),
      _mask = (BigInt.one << 5 * (length - 1)) - BigInt.one;

  final int length;
  final List<BigInt> _generators;
  final BigInt _plain;
  final BigInt _modified;
  final int _shift;
  final BigInt _mask;

  bool verifies(String hrp, List<int> values) {
    var check = BigInt.one;
    for (final value in [
      for (final unit in hrp.codeUnits) unit >> 5,
      0,
      for (final unit in hrp.codeUnits) unit & 31,
      ...values,
    ]) {
      final top = (check >> _shift).toInt();
      check = (check & _mask) << 5 ^ BigInt.from(value);
      for (var i = 0; i < 5; i++) {
        if (top >> i & 1 == 1) check ^= _generators[i];
      }
    }
    return check == (values.first == 0 ? _plain : _modified);
  }
}

final _bech32 = _Checksum(
  6,
  ['3b6a57b2', '26508e6d', '1ea119fa', '3d4233dd', '2a1462b3'],
  '1',
  '2bc830a3',
);

final _blech32 = _Checksum(
  12,
  [
    '7d52fba40bd886',
    '5e8dbf1a03950c',
    '1c3a3c74072a18',
    '385d72fa0e5139',
    '7093e5a608865b',
  ],
  '1',
  '455972a3350f7a1',
);

ChainAddress? _segwitAddress(String text) {
  final address = text.toLowerCase();
  if (text != address && text != text.toUpperCase()) return null;
  final separator = address.lastIndexOf('1');
  if (separator < 1) return null;
  final hrp = address.substring(0, separator);
  final (network, confidential) = switch (hrp) {
    'lq' => (ChainNetwork.liquid, true),
    'ex' => (ChainNetwork.liquid, false),
    'tlq' => (ChainNetwork.liquidTestnet, true),
    'tex' => (ChainNetwork.liquidTestnet, false),
    _ => (null, false),
  };
  if (network == null) return null;

  final values = [
    for (final char in address.substring(separator + 1).split(''))
      _charset.indexOf(char),
  ];
  final checksum = confidential ? _blech32 : _bech32;
  if (values.length <= checksum.length || values.contains(-1)) return null;
  final version = values.first;
  if (version > 16 || !checksum.verifies(hrp, values)) return null;

  final data = _bytes(values.sublist(1, values.length - checksum.length));
  if (data == null) return null;
  final List<int> program;
  if (confidential) {
    if (data.length < 33 || !_isPubkeyPrefix(data.first)) return null;
    program = data.sublist(33);
  } else {
    program = data;
  }
  if (program.length < 2 || program.length > 40) return null;
  if (version == 0 && program.length != 20 && program.length != 32) {
    return null;
  }
  return ChainAddress(address, network: network);
}

/// 5-bit words to bytes, rejecting leftover bits as BIP-173 does.
List<int>? _bytes(List<int> words) {
  final bytes = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final word in words) {
    buffer = (buffer << 5 | word) & 0xfff;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      bytes.add(buffer >> bits & 0xff);
    }
  }
  if (bits >= 5 || buffer << (8 - bits) & 0xff != 0) return null;
  return bytes;
}

bool _isPubkeyPrefix(int byte) => byte == 2 || byte == 3;

/// Base58 version bytes: pay to pubkey hash, pay to script hash, and the
/// one in front of either for a confidential address.
const _base58Prefixes = [
  (ChainNetwork.liquid, p2pkh: 57, p2sh: 39, confidential: 12),
  (ChainNetwork.liquidTestnet, p2pkh: 36, p2sh: 19, confidential: 23),
];

ChainAddress? _base58Address(String text) {
  final data = _base58Check(text);
  if (data == null) return null;
  for (final (network, :p2pkh, :p2sh, :confidential) in _base58Prefixes) {
    bool isHash(int prefix) => prefix == p2pkh || prefix == p2sh;
    final matches = switch (data.length) {
      21 => isHash(data[0]),
      55 =>
        data[0] == confidential && isHash(data[1]) && _isPubkeyPrefix(data[2]),
      _ => false,
    };
    if (matches) return ChainAddress(text, network: network);
  }
  return null;
}

const _alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// The payload of a Base58Check string, or null when its checksum fails.
List<int>? _base58Check(String text) {
  if (text.isEmpty || text.length > 150) return null;
  var value = BigInt.zero;
  for (final char in text.split('')) {
    final digit = _alphabet.indexOf(char);
    if (digit < 0) return null;
    value = value * BigInt.from(58) + BigInt.from(digit);
  }
  final zeros = text.length - text.replaceFirst(RegExp('^1+'), '').length;
  final hex = value == BigInt.zero ? '' : value.toRadixString(16);
  final digits = hex.padLeft(hex.length + hex.length % 2, '0');
  final bytes = [
    ...List.filled(zeros, 0),
    for (var i = 0; i < digits.length; i += 2)
      int.parse(digits.substring(i, i + 2), radix: 16),
  ];
  if (bytes.length < 5) return null;
  final payload = bytes.sublist(0, bytes.length - 4);
  final hash = sha256.convert(sha256.convert(payload).bytes).bytes;
  for (var i = 0; i < 4; i++) {
    if (hash[i] != bytes[payload.length + i]) return null;
  }
  return payload;
}
