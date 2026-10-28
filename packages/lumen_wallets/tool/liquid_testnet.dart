// Syncs a Liquid testnet wallet through LWK. With --send, pays 1000 sats to
// itself; with --send-all <address>, sends that address everything. From
// packages/lumen_wallets:
//
//   cargo build --release --manifest-path ../lumen_core/rust/Cargo.toml
//   LUMEN_TESTNET_PHRASE="twelve words ..." dart run tool/liquid_testnet.dart

import 'dart:io';

import 'package:lumen_wallets/lumen_wallets.dart';

Future<void> main(List<String> args) async {
  final library = switch (Platform.operatingSystem) {
    'macos' => 'liblumen_core.dylib',
    'windows' => 'lumen_core.dll',
    _ => 'liblumen_core.so',
  };
  await LwkEngine.init(
    libraryPath: '../lumen_core/rust/target/release/$library',
  );

  const network = ChainNetwork.liquidTestnet;
  final source = LiquidWalletSource(
    engine: const LwkEngine(),
    secrets: MemoryKeyValueStore(),
    chainState: MemoryKeyValueStore(),
    networks: const {network},
  );
  var phrase = Platform.environment['LUMEN_TESTNET_PHRASE'] ?? '';
  if (phrase.isEmpty) {
    phrase = await source.newPhrase();
    print('New phrase: $phrase');
  }

  final watch = Stopwatch()..start();
  final discovery = await source.discover(phrase, network: network);
  final wallet = await source.add(
    phrase: phrase,
    name: 'Testnet',
    network: network,
    discovery: discovery,
  );
  print('${discovery.script.name}, scanned in ${watch.elapsedMilliseconds} ms');
  print('Balance: ${await wallet.fetchBalance()} sats');
  for (final t in (await wallet.fetchTransactions(limit: 5)).transactions) {
    final state = t.isPending ? 'pending' : '${t.confirmations} conf';
    print('  ${t.direction.name} ${t.sats} sats, fee ${t.feeSats}, $state');
  }
  final address = await wallet.nextAddress();
  print('Receive at: ${address.address}');

  if (args.contains('--send')) {
    final quote = await wallet.prepareSend(address, sats: 1000);
    print('Fee: ${quote.feeSats} sats');
    final payment = await wallet.confirmSend(quote);
    print('Sent: ${payment.txid}');
    print('Balance: ${await wallet.fetchBalance()} sats');
  }

  final all = args.indexOf('--send-all');
  if (all >= 0) {
    final quote = await wallet.prepareSendAll(
      ChainAddress(args[all + 1], network: network),
    );
    print('Sending ${quote.sats} sats, fee ${quote.feeSats} sats');
    final payment = await wallet.confirmSend(quote);
    print('Sent: ${payment.txid}');
    print('Balance: ${await wallet.fetchBalance()} sats');
  }
}
