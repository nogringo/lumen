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
    paymentHash: result.paymentHash,
    feeSats: switch (result.feesPaid) {
      final msats? => (msats / 1000).ceil(),
      null => null,
    },
    preimage: _present(result.preimage),
    invoice: _present(result.invoice),
  );
}

String? _present(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();
