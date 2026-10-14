import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:test/test.dart';

import 'invoices.dart';

final _barista = parseRecipient('barista@example.com') as LnurlRecipient;

Matcher _fails(RecipientError error) =>
    throwsA(isA<RecipientException>().having((e) => e.error, 'error', error));

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

const _terms = {
  'tag': 'payRequest',
  'callback': 'https://example.com/lnurlp/barista/callback?id=7',
  'minSendable': 1000,
  'maxSendable': 100000000,
  'metadata': '[["text/plain","Barista"]]',
};

void main() {
  test('reads what the address accepts', () async {
    Uri? asked;
    final lnurl = LnurlPay(
      MockClient((request) async {
        asked = request.url;
        return _json(_terms);
      }),
    );

    final terms = await lnurl.terms(_barista);

    expect(asked, Uri.parse('https://example.com/.well-known/lnurlp/barista'));
    expect(terms.minSats, 1);
    expect(terms.maxSats, 100000);
    expect(terms.accepts(100000), isTrue);
    expect(terms.accepts(100001), isFalse);
  });

  test('asks the callback for an invoice of the exact amount', () async {
    Uri? asked;
    final lnurl = LnurlPay(
      MockClient((request) async {
        if (request.url.path.endsWith('callback')) {
          asked = request.url;
          return _json({'pr': donationInvoice, 'routes': []});
        }
        return _json(_terms);
      }),
    );

    final invoice = await lnurl.invoice(await lnurl.terms(_barista), 138);

    expect(asked!.queryParameters, {'id': '7', 'amount': '138000'});
    expect(invoice.request, donationInvoice);
    expect(invoice.sats, 138);
    expect(invoice.description, 'Donation to Nicolas Dorier');
  });

  test('an invoice for another amount is refused', () async {
    final lnurl = LnurlPay(
      MockClient(
        (request) async => request.url.path.endsWith('callback')
            ? _json({'pr': donationInvoice})
            : _json(_terms),
      ),
    );
    final terms = await lnurl.terms(_barista);

    await expectLater(
      lnurl.invoice(terms, 139),
      _fails(RecipientError.wrongInvoice),
    );
  });

  test('a service that answers with an error refuses the payment', () async {
    final lnurl = LnurlPay(
      MockClient(
        (_) async =>
            _json({'status': 'ERROR', 'reason': 'User not found'}, 404),
      ),
    );

    await expectLater(lnurl.terms(_barista), _fails(RecipientError.refused));
  });

  test('a service that cannot be read is unreachable', () async {
    for (final client in [
      MockClient((_) async => http.Response('Not found', 404)),
      MockClient((_) async => throw http.ClientException('offline')),
      MockClient(
        (_) async => _json({..._terms, 'callback': 'http://example.com/cb'}),
      ),
      MockClient((_) async => _json({..._terms, 'tag': 'withdrawRequest'})),
    ]) {
      await expectLater(
        LnurlPay(client).terms(_barista),
        _fails(RecipientError.unreachable),
      );
    }
  });
}
