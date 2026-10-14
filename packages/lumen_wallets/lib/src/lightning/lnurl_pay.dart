import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../wallet.dart';
import 'bolt11.dart';
import 'recipient.dart';

/// What an LNURL-pay service accepts (LUD-06).
final class PayTerms {
  const PayTerms({
    required this.recipient,
    required this.callback,
    required this.minSats,
    required this.maxSats,
  });

  final LnurlRecipient recipient;
  final Uri callback;
  final int minSats;
  final int maxSats;

  bool accepts(int sats) => sats >= minSats && sats <= maxSats;
}

/// Asks Lightning addresses and LNURLs for invoices (LUD-06, LUD-16).
final class LnurlPay {
  LnurlPay(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 20);

  /// Throws a [RecipientException] when the service cannot be paid.
  Future<PayTerms> terms(LnurlRecipient recipient) async {
    final json = await _get(recipient.url);
    final callback = Uri.tryParse('${json['callback']}');
    final minSendable = json['minSendable'];
    final maxSendable = json['maxSendable'];
    if (json['tag'] != 'payRequest' ||
        callback == null ||
        !_isSafe(callback) ||
        minSendable is! num ||
        maxSendable is! num) {
      throw const RecipientException(RecipientError.unreachable);
    }
    final terms = PayTerms(
      recipient: recipient,
      callback: callback,
      minSats: max(1, (minSendable / 1000).ceil()),
      maxSats: maxSendable ~/ 1000,
    );
    if (terms.maxSats < terms.minSats) {
      throw const RecipientException(RecipientError.refused);
    }
    return terms;
  }

  /// An invoice for [sats], checked to ask exactly that amount. Throws a
  /// [RecipientException] when the service does not give one.
  Future<Invoice> invoice(PayTerms terms, int sats) async {
    final msats = sats * 1000;
    final callback = terms.callback;
    final json = await _get(
      callback.replace(
        queryParameters: {...callback.queryParameters, 'amount': '$msats'},
      ),
    );
    final request = json['pr'];
    final bolt11 = request is String ? decodeBolt11(request) : null;
    if (bolt11 == null) {
      throw const RecipientException(RecipientError.unreachable);
    }
    // LUD-06: never pay an invoice for another amount than the one asked.
    if (bolt11.msats != msats) {
      throw const RecipientException(RecipientError.wrongInvoice);
    }
    return invoiceFrom(bolt11, msats);
  }

  Future<Map<String, dynamic>> _get(Uri url) async {
    final http.Response response;
    final Object? json;
    try {
      response = await _client
          .get(url, headers: const {'Accept': 'application/json'})
          .timeout(_timeout);
      json = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw const RecipientException(RecipientError.unreachable);
    }
    if (json is! Map<String, dynamic>) {
      throw const RecipientException(RecipientError.unreachable);
    }
    if ('${json['status']}'.toUpperCase() == 'ERROR') {
      throw const RecipientException(RecipientError.refused);
    }
    if (response.statusCode != 200) {
      throw const RecipientException(RecipientError.unreachable);
    }
    return json;
  }

  bool _isSafe(Uri url) =>
      url.isScheme('https') ||
      (url.isScheme('http') && url.host.endsWith('.onion'));
}
