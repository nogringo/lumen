import 'dart:convert';

import 'package:bech32/bech32.dart';

/// The fields of a BOLT11 payment request that Lumen shows or checks. The
/// signature is not verified: the paying wallet does that.
final class Bolt11 {
  const Bolt11({
    required this.request,
    required this.msats,
    required this.createdAt,
    required this.expiry,
    this.paymentHash,
    this.description,
  });

  /// In lower case.
  final String request;

  /// Null when the invoice leaves the amount to the payer.
  final int? msats;
  final DateTime createdAt;
  final Duration expiry;
  final String? paymentHash;
  final String? description;

  DateTime get expiresAt => createdAt.add(expiry);
}

final _prefix = RegExp(r'^ln(bcrt|bc|tbs|tb|sb)(\d+)?([munp])?$');

const _timestampWords = 7;
const _signatureWords = 104;
const _paymentHashWords = 52;
const _paymentHashTag = 1;
const _descriptionTag = 13;
const _expiryTag = 6;
const _defaultExpiry = Duration(hours: 1);

/// Above this, amounts lose precision in JavaScript numbers on the web.
final _maxMsats = BigInt.from(9007199254740991);

/// Decodes [request], or returns null when it is not a valid BOLT11 invoice.
Bolt11? decodeBolt11(String request) {
  final lower = request.trim().toLowerCase();
  final Bech32 decoded;
  try {
    decoded = const Bech32Codec().decode(lower, lower.length);
  } catch (_) {
    return null;
  }

  final prefix = _prefix.firstMatch(decoded.hrp);
  if (prefix == null) return null;
  final int? msats;
  if (prefix.group(2) case final digits?) {
    msats = _msats(digits, prefix.group(3));
    if (msats == null) return null;
  } else {
    msats = null;
  }

  final words = decoded.data;
  final end = words.length - _signatureWords;
  if (end < _timestampWords) return null;
  final createdAt = DateTime.fromMillisecondsSinceEpoch(
    _number(words.sublist(0, _timestampWords)) * 1000,
    isUtc: true,
  );

  String? paymentHash;
  String? description;
  var expiry = _defaultExpiry;
  var i = _timestampWords;
  while (i < end) {
    if (i + 3 > end) return null;
    final tag = words[i];
    final length = words[i + 1] * 32 + words[i + 2];
    final start = i + 3;
    if (start + length > end) return null;
    final data = words.sublist(start, start + length);
    i = start + length;

    switch (tag) {
      // BOLT11 says to skip a payment hash of the wrong length.
      case _paymentHashTag when length == _paymentHashWords:
        paymentHash = wordsToBytes(data)
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join();
      case _descriptionTag:
        try {
          description = utf8.decode(wordsToBytes(data));
        } on FormatException {
          return null;
        }
      case _expiryTag:
        expiry = Duration(seconds: _number(data));
    }
  }

  return Bolt11(
    request: lower,
    msats: msats,
    createdAt: createdAt,
    expiry: expiry,
    paymentHash: paymentHash,
    description: description,
  );
}

int? _msats(String digits, String? multiplier) {
  final amount = BigInt.parse(digits);
  final msats = switch (multiplier) {
    null => amount * BigInt.from(100000000000),
    'm' => amount * BigInt.from(100000000),
    'u' => amount * BigInt.from(100000),
    'n' => amount * BigInt.from(100),
    // A pico-bitcoin is a tenth of a millisatoshi.
    _ when amount % BigInt.from(10) != BigInt.zero => null,
    _ => amount ~/ BigInt.from(10),
  };
  if (msats == null || msats <= BigInt.zero || msats > _maxMsats) return null;
  return msats.toInt();
}

/// Multiplies rather than shifts: the web's bitwise operators stop at 32 bits.
int _number(List<int> words) =>
    words.fold(0, (value, word) => value * 32 + word);

/// Regroups bech32 5-bit words into bytes, dropping the padding bits at the end.
List<int> wordsToBytes(List<int> words) {
  final bytes = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final word in words) {
    buffer = ((buffer << 5) | word) & 0xfff;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      bytes.add((buffer >> bits) & 0xff);
    }
  }
  return bytes;
}
