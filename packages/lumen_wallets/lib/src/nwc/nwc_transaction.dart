import 'package:ndk/ndk.dart' show TransactionResult;

import '../wallet.dart';

/// The settled payment [result] describes, or null when it is pending, failed
/// or expired. Wallets that omit the optional `state` only list settled ones.
Transaction? nwcTransaction(TransactionResult result) {
  final state = result.state;
  if (state != null && state != 'settled') return null;
  final description = result.description?.trim();
  return Transaction(
    id: result.paymentHash,
    direction: result.isIncoming
        ? TransactionDirection.incoming
        : TransactionDirection.outgoing,
    sats: result.amountSat,
    at: DateTime.fromMillisecondsSinceEpoch(
      (result.settledAt ?? result.createdAt) * 1000,
    ),
    description: description == null || description.isEmpty
        ? null
        : description,
  );
}
