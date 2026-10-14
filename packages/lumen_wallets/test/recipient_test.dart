import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:test/test.dart';

import 'invoices.dart';

Matcher _fails(RecipientError error) =>
    throwsA(isA<RecipientException>().having((e) => e.error, 'error', error));

void main() {
  test('an invoice is paid as is', () {
    final recipient = parseRecipient(coffeeInvoice) as InvoiceRecipient;
    final invoice = recipient.invoice;

    expect(invoice.request, coffeeInvoice);
    expect(invoice.sats, 250000);
    expect(invoice.description, '1 cup coffee');
    expect(
      invoice.expiresAt,
      DateTime.fromMillisecondsSinceEpoch(1496314718000, isUtc: true),
    );
  });

  test('a lightning: link or a QR code in upper case is an invoice', () {
    for (final input in [
      'lightning:$coffeeInvoice',
      'LIGHTNING:${coffeeInvoice.toUpperCase()}',
      'lightning://$coffeeInvoice',
    ]) {
      final recipient = parseRecipient(input) as InvoiceRecipient;
      expect(recipient.invoice.request, coffeeInvoice, reason: input);
    }
  });

  test('a bitcoin: link pays its Lightning invoice', () {
    final recipient = parseRecipient(
      'bitcoin:bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq?amount=0.0025&lightning=$coffeeInvoice',
    ) as InvoiceRecipient;

    expect(recipient.invoice.sats, 250000);
  });

  test('a bitcoin: link without an invoice cannot be paid', () {
    expect(
      () =>
          parseRecipient('bitcoin:bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'),
      _fails(RecipientError.unrecognized),
    );
  });

  test('an invoice without amount cannot be paid', () {
    expect(
      () => parseRecipient(anyAmountInvoice),
      _fails(RecipientError.invoiceWithoutAmount),
    );
  });

  test('a Lightning address points at its LNURL-pay endpoint', () {
    final recipient = parseRecipient(' Barista@Example.com ') as LnurlRecipient;

    expect(recipient.address, 'barista@example.com');
    expect(recipient.label, 'barista@example.com');
    expect(
      recipient.url,
      Uri.parse('https://example.com/.well-known/lnurlp/barista'),
    );
  });

  test('an onion address is reached over HTTP', () {
    final recipient = parseRecipient('tip@abcdef.onion') as LnurlRecipient;

    expect(recipient.url.scheme, 'http');
  });

  test('an LNURL is decoded to its URL', () {
    final recipient = parseRecipient(
      'lightning:LNURL1DP68GURN8GHJ7UM9WFMXJCM99E3K7MF0V9CXJ0M385EKVCENXC6R2C35XVUKXEFCV5MKVV34X5EKZD3EV56NYD3HXQURZEPEXEJXXEPNXSCRVWFNV9NXZCN9XQ6XYEFHVGCXXCMYXYMNSERXFQ5FNS',
    ) as LnurlRecipient;

    expect(
      recipient.url,
      Uri.parse(
        'https://service.com/api?q=3fc3645b439ce8e7f2553a69e5267081d96dcd340693afabe04be7b0ccd178df',
      ),
    );
    expect(recipient.address, isNull);
    expect(recipient.label, 'service.com');
  });

  test('an lnurlp:// link is fetched over HTTPS', () {
    final recipient =
        parseRecipient('lnurlp://pay.example.com/u/barista') as LnurlRecipient;

    expect(recipient.url, Uri.parse('https://pay.example.com/u/barista'));
  });

  test('anything else is not recognized', () {
    for (final input in ['', 'hello', 'barista@', '@example.com', 'lnbc1']) {
      expect(
        () => parseRecipient(input),
        _fails(RecipientError.unrecognized),
        reason: input,
      );
    }
  });
}
