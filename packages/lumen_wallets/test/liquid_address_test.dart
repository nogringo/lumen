import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:lumen_wallets/src/liquid/liquid_address.dart';
import 'package:test/test.dart';

// From the tests of the elements crate, which LWK builds on.
const _mainnet = [
  'lq1qqf8er278e6nyvuwtgf39e6ewvdcnjupn9a86rzpx655y5lhkt0walu3djf9cklkxd3ryld97hu8h3xepw7sh2rlu7q45dcew5',
  'lq1qqgft7r4ytdenml0gaj67393sd3qkt3nxex0ut5dt3plhzwf6jaww4casc3pf3lquzjd0haxgn9hmjfp84eq7geymjdx2f9verdu99wz47jmkmgmr9a4s',
  'lq1pqgft7r4ytdenml0gaj67393sd3qkt3nxex0ut5dt3plhzwf6jaww5wpq7p3x4f75f5gch3gktgxxwu2rxm394tsw8dchxedsc6r53w75375l4kfvf08y',
  'ex1q7gkeyjut0mrxc3j0kjlt7rmcnvsh0gt45d3fud',
  'ex1quwcvgs5clswpfxhm7nyfjmaeysn6us0yvjdexn9yjkv3k7zjhp2s4sla8h',
  'ex1p8qs0qcn25l2y6yvtc5t95rr8w9pndcj64c8rkutnvkcvdp6gh02qa4lw5j',
  'VJLDwMVWXg8RKq4mRe3YFNTAEykVN6V8x5MRUKKoC3nfRnbpnZeiG3jygMC6A4Gw967GY5EotJ4Rau2F',
  'VTptY6cqJbusNpL5xvo8VL38nLX9PGDjfYQfqhu9EaA7FtuidkWyQzMHY9jzZrpBcCXT437vM6V4N8kh',
  'QFq3vvrr6Ub2KAyb3LdoCxEQvKukB6nN9i',
  'GqiQRsPEyJLAsEBFB5R34KHuqxDNkG3zur',
  'H55PJDhj6JpR5k9wViXGEX4nga8WmhXtnD',
];

const _testnet = [
  'tlq1qq2xvpcvfup5j8zscjq05u2wxxjcyewk7979f3mmz5l7uw5pqmx6xf5xy50hsn6vhkm5euwt72x878eq6zxx2z58hd7zrsg9qn',
  'tlq1pqgft7r4ytdenml0gaj67393sd3qkt3nxex0ut5dt3plhzwf6jaww5vx8c8vs0ywzejta7jjcc5f4asnacdtu0wlaas0upmsq90enaz2lekytucqf82vs',
  'tex1qew0l0emv7449u7hqgc8utzdzryhse79yh5jp9a',
  'tex1pxrrurkg8j8pve97lffvv2y67cf7ux478h077c87qacqzhue7390skzlycz',
  'vtS71VhcpFt978sha5d1L2gCzp3UL5kXacRpb3N4GTW5MwvBzz5HwxYyB8Pns4yM2dd2osmQkHSkp88u',
  'vjTuLJ76nGi8PUopBVmGK8bLKPfBpaBWf6wKfn8z9Vdz6ubVhpvmMr6TK2RcqAYiujN1g1uwg8kejrM3',
  'FojPFeboBgrd953mXXe72KWthjVwHWozqN',
  '8vsafXgrB5bJeSidGbK5eYnjKvQ3RiB4BB',
];

void main() {
  test('reads mainnet addresses of every kind', () {
    for (final text in _mainnet) {
      final address = liquidAddress(text);
      expect(address?.network, ChainNetwork.liquid, reason: text);
      expect(address?.address, text, reason: text);
    }
  });

  test('reads testnet addresses of every kind', () {
    for (final text in _testnet) {
      expect(
        liquidAddress(text)?.network,
        ChainNetwork.liquidTestnet,
        reason: text,
      );
    }
  });

  test('an address in upper case, as in a QR code, is read in lower case', () {
    final address = liquidAddress(_mainnet.first.toUpperCase());

    expect(address?.address, _mainnet.first);
  });

  test('a typo breaks the checksum', () {
    for (final text in [..._mainnet, ..._testnet]) {
      final typo =
          text.substring(0, 20) +
          (text[20] == 'q' ? 'p' : 'q') +
          text.substring(21);
      expect(liquidAddress(typo), isNull, reason: typo);
    }
  });

  test('mixed case, other networks and other coins are not Liquid', () {
    for (final text in [
      'lq1qqF8er278e6nyvuwtgf39e6ewvdcnjupn9a86rzpx655y5lhkt0walu3djf9cklkxd3ryld97hu8h3xepw7sh2rlu7q45dcew5',
      'el1qqgft7r4ytdenml0gaj67393sd3qkt3nxex0ut5dt3plhzwf6jaww4jul7lnkeat2teawq3s0cky6yxf0pnu2gmz9ej9kyq5yc',
      'ert1qew0l0emv7449u7hqgc8utzdzryhse79yhq2sxv',
      'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
      '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      'lq1',
      '',
    ]) {
      expect(liquidAddress(text), isNull, reason: text);
    }
  });

  group('requests', () {
    test('without an amount, the address is the request', () {
      final address = liquidAddress(_mainnet.first)!;

      expect(liquidRequest(address), _mainnet.first);
    });

    test('an amount makes a URI in L-BTC that reads back', () {
      for (final (sats, amount) in [
        (21000, '0.00021'),
        (1, '0.00000001'),
        (150000000, '1.5'),
        (200000000, '2'),
      ]) {
        final request = liquidRequest(
          ChainAddress(
            _mainnet.first,
            network: ChainNetwork.liquid,
            sats: sats,
          ),
        );

        expect(
          request,
          'liquidnetwork:${_mainnet.first}?amount=$amount'
          '&assetid=${lbtcAssetIds[ChainNetwork.liquid]}',
        );
        final read = parseRecipient(request) as AddressRecipient;
        expect(
          (read.address.address, read.address.sats),
          (_mainnet.first, sats),
        );
      }
    });

    test('testnet has its own scheme and asset', () {
      final request = liquidRequest(
        ChainAddress(
          _testnet.first,
          network: ChainNetwork.liquidTestnet,
          sats: 5000,
        ),
      );

      expect(request, startsWith('liquidtestnet:${_testnet.first}?'));
      expect(
        (parseRecipient(
          request,
          networks: {ChainNetwork.liquidTestnet},
        ) as AddressRecipient).address.sats,
        5000,
      );
    });
  });
}
