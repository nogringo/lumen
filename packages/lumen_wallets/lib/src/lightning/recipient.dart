import 'dart:convert';

import 'package:bech32/bech32.dart';

import '../wallet.dart';
import 'bolt11.dart';

enum RecipientError {
  /// Not a Lightning invoice, Lightning address or LNURL.
  unrecognized,

  /// An invoice that leaves the amount to the payer, which NWC cannot pay.
  invoiceWithoutAmount,

  /// The address's service did not answer, or answered something invalid.
  unreachable,

  /// The address's service answered that it cannot be paid.
  refused,

  /// The service sent an invoice for another amount than the one asked.
  wrongInvoice,
}

class RecipientException implements Exception {
  const RecipientException(this.error);

  final RecipientError error;

  @override
  String toString() => 'RecipientException(${error.name})';
}

/// Where a payment goes, read from what the user typed, pasted or scanned.
sealed class Recipient {
  const Recipient();
}

final class InvoiceRecipient extends Recipient {
  const InvoiceRecipient(this.invoice);

  final Invoice invoice;
}

/// A Lightning address or an LNURL: a service that makes invoices for the
/// amount the payer picks (LNURL-pay).
final class LnurlRecipient extends Recipient {
  const LnurlRecipient(this.url, {this.address});

  final Uri url;

  /// The `name@domain` address, when the recipient was given as one.
  final String? address;

  /// The address, or the domain of an LNURL.
  String get label => address ?? url.host;
}

final _address = RegExp(
  r'^([a-z0-9\-_.+]+)@([a-z0-9\-]+(\.[a-z0-9\-]+)*\.[a-z]{2,})$',
);

/// Reads [input]. Throws a [RecipientException] when it is not something
/// Lumen can pay.
Recipient parseRecipient(String input) {
  var value = input.trim();
  final lower = value.toLowerCase();
  if (lower.startsWith('lightning:')) {
    value = value.substring('lightning:'.length).replaceFirst('//', '');
  } else if (lower.startsWith('bitcoin:')) {
    // BIP-21: a Lightning invoice can ride along an on-chain address.
    final lightning = Uri.tryParse(value)?.queryParameters.entries
        .where((entry) => entry.key.toLowerCase() == 'lightning')
        .firstOrNull
        ?.value;
    if (lightning == null) {
      throw const RecipientException(RecipientError.unrecognized);
    }
    value = lightning;
  }
  value = value.trim();
  final normalized = value.toLowerCase();

  if (normalized.startsWith('lnurl1')) return _bech32Lnurl(normalized);
  if (normalized.startsWith('lnurlp://')) {
    final url = Uri.tryParse(value.replaceFirst(RegExp('^lnurlp'), 'https'));
    if (url == null || url.host.isEmpty) {
      throw const RecipientException(RecipientError.unrecognized);
    }
    return LnurlRecipient(_onionAware(url));
  }

  if (_address.firstMatch(normalized) case final match?) {
    final name = match.group(1)!;
    final domain = match.group(2)!;
    return LnurlRecipient(
      _onionAware(Uri.https(domain, '/.well-known/lnurlp/$name')),
      address: normalized,
    );
  }

  if (normalized.startsWith('ln')) {
    final bolt11 = decodeBolt11(normalized);
    if (bolt11 != null) {
      final msats = bolt11.msats;
      if (msats == null) {
        throw const RecipientException(RecipientError.invoiceWithoutAmount);
      }
      return InvoiceRecipient(invoiceFrom(bolt11, msats));
    }
  }
  throw const RecipientException(RecipientError.unrecognized);
}

Invoice invoiceFrom(Bolt11 bolt11, int msats) {
  final description = bolt11.description?.trim();
  return Invoice(
    request: bolt11.request,
    sats: (msats / 1000).ceil(),
    paymentHash: bolt11.paymentHash,
    expiresAt: bolt11.expiresAt,
    description: description == null || description.isEmpty
        ? null
        : description,
  );
}

LnurlRecipient _bech32Lnurl(String lnurl) {
  try {
    final decoded = const Bech32Codec().decode(lnurl, lnurl.length);
    final url = Uri.parse(utf8.decode(wordsToBytes(decoded.data)));
    if (url.host.isNotEmpty && (url.isScheme('https') || _isOnion(url))) {
      return LnurlRecipient(url);
    }
  } catch (_) {
    // Reported below.
  }
  throw const RecipientException(RecipientError.unrecognized);
}

bool _isOnion(Uri url) => url.host.endsWith('.onion');

/// LUD-17: onion services are reached over plain HTTP, through Tor.
Uri _onionAware(Uri url) => _isOnion(url) ? url.replace(scheme: 'http') : url;
