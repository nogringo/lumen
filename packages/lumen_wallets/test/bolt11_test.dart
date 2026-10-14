import 'package:lumen_wallets/src/lightning/bolt11.dart';
import 'package:test/test.dart';

import 'invoices.dart';

void main() {
  test('reads amount, description, expiry and payment hash', () {
    final invoice = decodeBolt11(coffeeInvoice)!;

    expect(invoice.msats, 250000000);
    expect(invoice.description, '1 cup coffee');
    expect(
      invoice.paymentHash,
      '0001020304050607080900010203040506070809000102030405060708090102',
    );
    expect(
      invoice.createdAt,
      DateTime.fromMillisecondsSinceEpoch(1496314658000, isUtc: true),
    );
    expect(invoice.expiry, const Duration(seconds: 60));
  });

  test('reads amounts in every unit', () {
    expect(decodeBolt11(donationInvoice)!.msats, 138000);
    expect(decodeBolt11(oneBitcoinInvoice)!.msats, 100000000000);
    expect(decodeBolt11(testnetInvoice)!.msats, 2000000000);
    expect(decodeBolt11(simnetInvoice)!.msats, 2030000);
  });

  test('an invoice without amount has none', () {
    final invoice = decodeBolt11(anyAmountInvoice)!;

    expect(invoice.msats, isNull);
    expect(invoice.description, 'Please consider supporting this project');
  });

  test('expiry defaults to one hour', () {
    expect(decodeBolt11(testnetInvoice)!.expiry, const Duration(hours: 1));
    expect(
      decodeBolt11(donationInvoice)!.expiry,
      const Duration(seconds: 1799),
    );
  });

  test('descriptions are UTF-8', () {
    expect(decodeBolt11(japaneseInvoice)!.description, 'ナンセンス 1杯');
  });

  test('upper case and surrounding spaces are accepted', () {
    final invoice = decodeBolt11('  ${coffeeInvoice.toUpperCase()}\n')!;

    expect(invoice.request, coffeeInvoice);
    expect(invoice.msats, 250000000);
  });

  test('a typo fails the checksum', () {
    final typo = coffeeInvoice.replaceRange(40, 41, 'z');

    expect(decodeBolt11(typo), isNull);
  });

  test('other text is not an invoice', () {
    expect(decodeBolt11(''), isNull);
    expect(decodeBolt11('barista@example.com'), isNull);
    expect(decodeBolt11('lnbc1'), isNull);
  });
}
