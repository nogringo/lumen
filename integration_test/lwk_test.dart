// Runs the LWK the app bundles, on the platform it was built for:
//
//   flutter test integration_test -d macos

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lumen_wallets/liquid_engine.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

const _phrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
const _address =
    'lq1qqvxk052kf3qtkxmrakx50a9gc3smqad2ync54hzntjt980kfej9kkfe0247rp5h4yzmdftsahhw64uy8pzfe7cpg4fgykm7cv';

// Nothing listens there, so a sync fails at once, without the network.
const _nowhere = LiquidServers(esplora: 'http://127.0.0.1:9');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the bundled LWK checks phrases, derives and syncs', (
    tester,
  ) async {
    const engine = LwkEngine();
    await engine.ready();
    expect(engine.phraseProblem(_phrase), isNull);
    expect(engine.phraseProblem(engine.generatePhrase()), isNull);

    final chain = await engine.open(
      phrase: _phrase,
      network: ChainNetwork.liquid,
      script: LiquidScript.nativeSegwit,
      servers: _nowhere,
      state: const [],
    );
    expect(await chain.nextAddress(), _address);
    await expectLater(
      chain.sync(),
      throwsA(
        isA<LiquidChainException>().having(
          (e) => e.error,
          'error',
          LiquidChainError.unreachable,
        ),
      ),
    );
  });
}
