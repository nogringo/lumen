import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:lumen_wallets/src/nwc/nwc_transaction.dart';
import 'package:ndk/ndk.dart' show TransactionResult;
import 'package:test/test.dart';

TransactionResult _result({
  String type = 'incoming',
  String? state,
  String? description,
  int? settledAt,
}) => TransactionResult(
  type: type,
  state: state,
  description: description,
  paymentHash: 'hash',
  amount: 40000500,
  createdAt: 1760000000,
  settledAt: settledAt,
);

void main() {
  test('reads amount in sats, direction and settle time', () {
    final transaction = nwcTransaction(
      _result(type: 'outgoing', state: 'settled', settledAt: 1760000060),
    )!;

    expect(transaction.id, 'hash');
    expect(transaction.sats, 40000);
    expect(transaction.direction, TransactionDirection.outgoing);
    expect(transaction.at.millisecondsSinceEpoch, 1760000060000);
  });

  test('falls back to the creation time without a settle time', () {
    final transaction = nwcTransaction(_result())!;

    expect(transaction.isIncoming, isTrue);
    expect(transaction.at.millisecondsSinceEpoch, 1760000000000);
  });

  test('skips payments that did not settle', () {
    for (final state in ['pending', 'failed', 'expired']) {
      expect(nwcTransaction(_result(state: state)), isNull, reason: state);
    }
  });

  test('drops a blank description', () {
    expect(nwcTransaction(_result(description: '  '))!.description, isNull);
    expect(
      nwcTransaction(_result(description: ' Coffee '))!.description,
      'Coffee',
    );
  });
}
