import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:test/test.dart';

import 'invoices.dart';

const _liquid =
    'lq1qqvp9g33gw9y05xava3dvcpq8pnkv82yj3tdnzp547eyp9yrztz2lkyxrhscd55ev4p7lj2n72jtkn5u4xnj4v577c42jhf3ww';
const _testnet =
    'tlq1qq02egjncr8g4qn890mrw3jhgupwqymekv383lwpmsfghn36hac5ptpmeewtnftluqyaraa56ung7wf47crkn5fjuhk422d68m';
const _lbtc =
    '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d';

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

  test('a Liquid address is paid on chain, for the amount the payer picks', () {
    final recipient = parseRecipient(' $_liquid ') as AddressRecipient;

    expect(recipient.address.address, _liquid);
    expect(recipient.address.network, ChainNetwork.liquid);
    expect(recipient.address.sats, isNull);
  });

  test('a liquidnetwork: link or its QR code in upper case is an address', () {
    for (final input in [
      'liquidnetwork:$_liquid',
      'LIQUIDNETWORK:${_liquid.toUpperCase()}',
    ]) {
      final recipient = parseRecipient(input) as AddressRecipient;
      expect(recipient.address.address, _liquid, reason: input);
    }
  });

  test('a liquidnetwork: link sets the amount in L-BTC', () {
    for (final (amount, sats) in [
      ('0.00025', 25000),
      ('1', 100000000),
      ('21.00000001', 2100000001),
      ('0', null),
    ]) {
      final recipient = parseRecipient(
        'liquidnetwork:$_liquid?amount=$amount&assetid=$_lbtc&label=Shop',
      ) as AddressRecipient;
      expect(recipient.address.sats, sats, reason: amount);
    }
  });

  test('a liquidnetwork: link with a malformed amount cannot be paid', () {
    for (final amount in ['0.000000001', '-1', '1,5', '1e3', 'abc']) {
      expect(
        () => parseRecipient('liquidnetwork:$_liquid?amount=$amount'),
        _fails(RecipientError.unrecognized),
        reason: amount,
      );
    }
  });

  test('a request for another Liquid asset cannot be paid', () {
    const usdt =
        'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2';

    expect(
      () => parseRecipient('liquidnetwork:$_liquid?amount=10&assetid=$usdt'),
      _fails(RecipientError.unsupportedAsset),
    );
  });

  test('a required parameter Lumen does not know makes a link unpayable', () {
    expect(
      () => parseRecipient('liquidnetwork:$_liquid?req-somethingnew=1'),
      _fails(RecipientError.unrecognized),
    );
  });

  test('a testnet address is refused unless testnet is allowed', () {
    for (final input in [_testnet, 'liquidtestnet:${_testnet.toUpperCase()}']) {
      expect(
        () => parseRecipient(input),
        _fails(RecipientError.wrongNetwork),
        reason: input,
      );
      final recipient = parseRecipient(
        input,
        networks: const {ChainNetwork.liquidTestnet},
      ) as AddressRecipient;
      expect(recipient.address.network, ChainNetwork.liquidTestnet);
    }
  });

  test('a testnet link for testnet L-BTC is accepted on testnet', () {
    const testnetLbtc =
        '144c654344aa716d6f3abcc1ca90e5641e4e2a7f633bc09fe3baf64585819a49';
    final recipient = parseRecipient(
      'liquidtestnet:$_testnet?amount=0.001&assetid=$testnetLbtc',
      networks: const {ChainNetwork.liquidTestnet},
    ) as AddressRecipient;

    expect(recipient.address.sats, 100000);
  });

  test('a mistyped Liquid address is not recognized', () {
    final typo = '${_liquid.substring(0, 30)}x${_liquid.substring(31)}';
    for (final input in [typo, 'liquidnetwork:$typo', 'liquidnetwork:']) {
      expect(
        () => parseRecipient(input),
        _fails(RecipientError.unrecognized),
        reason: input,
      );
    }
  });
}
