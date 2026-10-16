import 'dart:convert';

import 'package:bech32/bech32.dart';

import '../liquid/liquid_address.dart';
import '../wallet.dart';
import 'bolt11.dart';

enum RecipientError {
  /// Not a Lightning invoice, Lightning address, LNURL or Liquid address.
  unrecognized,

  /// An invoice that leaves the amount to the payer, which NWC cannot pay.
  invoiceWithoutAmount,

  /// The address's service did not answer, or answered something invalid.
  unreachable,

  /// The address's service answered that it cannot be paid.
  refused,

  /// The service sent an invoice for another amount than the one asked.
  wrongInvoice,

  /// An address from a network Lumen does not pay on here, such as testnet.
  wrongNetwork,

  /// A request for a Liquid asset other than L-BTC.
  unsupportedAsset,
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

/// A Liquid address that receives L-BTC, alone or in a `liquidnetwork:` URI
/// that may set the amount.
final class AddressRecipient extends Recipient {
  const AddressRecipient(this.address);

  final ChainAddress address;
}

final _address = RegExp(
  r'^([a-z0-9\-_.+]+)@([a-z0-9\-]+(\.[a-z0-9\-]+)*\.[a-z]{2,})$',
);

/// Reads [input]. Throws a [RecipientException] when it is not something
/// Lumen can pay, or is an address on another network than [networks].
Recipient parseRecipient(
  String input, {
  Set<ChainNetwork> networks = const {ChainNetwork.liquid},
}) {
  var value = input.trim();
  final lower = value.toLowerCase();
  if (lower.startsWith('liquidnetwork:') ||
      lower.startsWith('liquidtestnet:')) {
    return _liquidUri(value, networks);
  }
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
  if (liquidAddress(value) case final address?) {
    _checkNetwork(address, networks);
    return AddressRecipient(address);
  }
  throw const RecipientException(RecipientError.unrecognized);
}

void _checkNetwork(ChainAddress address, Set<ChainNetwork> networks) {
  if (!networks.contains(address.network)) {
    throw const RecipientException(RecipientError.wrongNetwork);
  }
}

/// A BIP-21 style URI, as the Blockstream app and Aqua make them. Its amount
/// is in L-BTC, as in BTC for `bitcoin:`.
AddressRecipient _liquidUri(String uri, Set<ChainNetwork> networks) {
  final body = uri.substring(uri.indexOf(':') + 1);
  final query = body.indexOf('?');
  final address = liquidAddress(query < 0 ? body : body.substring(0, query));
  if (address == null) {
    throw const RecipientException(RecipientError.unrecognized);
  }
  final Map<String, String> params;
  try {
    params = {
      for (final MapEntry(:key, :value) in Uri.splitQueryString(
        query < 0 ? '' : body.substring(query + 1),
      ).entries)
        key.toLowerCase(): value,
    };
  } on ArgumentError {
    throw const RecipientException(RecipientError.unrecognized);
  }
  // BIP-21: a required parameter Lumen does not know makes it unpayable.
  if (params.keys.any((key) => key.startsWith('req-'))) {
    throw const RecipientException(RecipientError.unrecognized);
  }

  _checkNetwork(address, networks);
  final asset = params['assetid']?.toLowerCase();
  if (asset != null && asset != lbtcAssetIds[address.network]) {
    throw const RecipientException(RecipientError.unsupportedAsset);
  }
  final amount = params['amount'] ?? '';
  final sats = amount.isEmpty
      ? null
      : _sats(amount) ??
            (throw const RecipientException(RecipientError.unrecognized));
  return AddressRecipient(
    ChainAddress(
      address.address,
      network: address.network,
      sats: sats == 0 ? null : sats,
    ),
  );
}

/// An amount in BTC units as sats, or null when it is not a valid one.
int? _sats(String amount) {
  final match = RegExp(r'^(\d{1,8})(?:\.(\d{0,8}))?$').firstMatch(amount);
  if (match == null) return null;
  final whole = int.parse(match.group(1)!);
  final fraction = int.parse((match.group(2) ?? '').padRight(8, '0'));
  return whole * 100000000 + fraction;
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
