// Renders the README screenshots from demo data:
// flutter test tool/screenshots_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../test/fakes.dart';

void main() {
  late WalletSources sources;

  setUpAll(() async {
    sources = memorySources();
    // Tests render every font as boxes until the real ones are loaded.
    final manifest = jsonDecode(
      await rootBundle.loadString('FontManifest.json'),
    ) as List<dynamic>;
    for (final family in manifest.cast<Map<String, dynamic>>()) {
      final loader = FontLoader(family['family'] as String);
      for (final font in family['fonts'] as List<dynamic>) {
        loader.addFont(rootBundle.load(font['asset'] as String));
      }
      await loader.load();
    }
  });
  tearDownAll(() => sources.dispose());

  List<FakeWallet> demoWallets() => [
    _DemoWallet(
        'home',
        'Home node',
        balance: 1250400,
        lightningAddress: 'satoshi@example.com',
      )
      ..transactions = [
        tx(
          'zap',
          sats: 21000,
          incoming: true,
          minutesAgo: 2,
          description: 'Zap from bob',
        ),
        tx(
          'c0ffee5e3b9a7d41f2e8c6a0b4d9e1f7a3c5b8d2e6f0a9c4b7d1e3f5a8c2b6d0',
          sats: 5400,
          minutesAgo: 34,
          description: 'Coffee',
          feeSats: 3,
          preimage: '9f2c4e81' * 8,
          invoice: fakeBolt11(5400, description: 'Coffee'),
        ),
        tx('salary', sats: 400000, incoming: true, days: 1),
      ],
    _DemoWallet('spending', 'Spending', balance: 84210)
      ..transactions = [
        tx('books', sats: 12500, days: 2, description: 'Bookshop'),
        tx('refund', sats: 3000, incoming: true, days: 3),
      ],
  ];

  Future<void> shoot(WidgetTester tester, String name, Size size) async {
    await tester.pumpAndSettle();
    final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
    await tester.runAsync(() async {
      final image = await layer.toImage(Offset.zero & size, pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('docs/screenshots/$name.png')
          .writeAsBytes(png!.buffer.asUint8List());
    });
  }

  for (final brightness in Brightness.values) {
    final theme = brightness.name;

    Future<void> pump(WidgetTester tester, Size size) async {
      await pumpLumen(
        tester,
        sources,
        wallets: demoWallets(),
        size: size,
        brightness: brightness,
      );
    }

    testWidgets('home, $theme', (tester) async {
      await pump(tester, phoneSize);
      await shoot(tester, 'home-$theme', phoneSize);
    });

    testWidgets('receive, $theme', (tester) async {
      await pump(tester, phoneSize);
      await tester.tap(find.text('Receive'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '21000');
      await tester.tap(find.text('Create invoice'));
      await shoot(tester, 'receive-$theme', phoneSize);
    });

    testWidgets('payment, $theme', (tester) async {
      await pump(tester, phoneSize);
      await tester.tap(find.text('Coffee'));
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await shoot(tester, 'payment-$theme', phoneSize);
    });

    testWidgets('desktop, $theme', (tester) async {
      await pump(tester, desktopSize);
      await shoot(tester, 'desktop-$theme', desktopSize);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  }
}

/// Makes invoices that look like real ones in the QR code and text.
class _DemoWallet extends FakeWallet {
  _DemoWallet(super.id, super.name, {super.balance, super.lightningAddress});

  @override
  Future<Invoice> createInvoice(int sats) async {
    final invoice = await super.createInvoice(sats);
    return Invoice(
      request: fakeBolt11(sats),
      sats: sats,
      paymentHash: invoice.paymentHash,
      expiresAt: invoice.expiresAt,
    );
  }
}
