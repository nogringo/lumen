import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/app.dart';
import 'package:lumen/lock/app_gate.dart';
import 'package:lumen/lock/app_lock.dart';
import 'package:lumen/lock/lock_store.dart';
import 'package:lumen/lock/sealed_storage.dart';
import 'package:lumen/settings/language.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

const _passphrase = 'correct horse battery';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  /// Lumen with one wallet, each unlock opening a fresh session.
  Future<AppGate> pumpGate(
    WidgetTester tester, {
    bool locked = false,
    LockStore? lockStore,
    Size size = phoneSize,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    // Sessions start ndk timers, so they are made on real time up front.
    final ready = <LumenSession>[];
    final gate = AppGate(
      lock: AppLock(lockStore ?? MemoryLockStore(), kdf: const FastKdf()),
      storage: SealedStorage(),
      openSession: () async => ready.removeAt(0),
    );
    await tester.runAsync(() async {
      for (var i = 0; i < 3; i++) {
        final wallets = await loadedController([
          FakeWallet('home', 'Home node', balance: 21000),
        ]);
        await wallets.refreshAll();
        ready.add(LumenSession(memorySources(), wallets));
      }
      await gate.start();
      if (locked) {
        await gate.enableLock(_passphrase);
        await gate.lockNow();
      }
    });
    addTearDown(
      () => tester.runAsync(() async {
        await gate.session?.close();
        for (final session in ready) {
          await session.close();
        }
      }),
    );
    await tester.pumpWidget(
      LumenApp(gate: gate, language: LanguageSetting(MemoryLanguageStore())),
    );
    await tester.pumpAndSettle();
    return gate;
  }

  /// Gate calls run on real time: Argon2 stand-ins and session setup await
  /// real futures.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await settle(tester);
  }

  Future<void> openSettings(WidgetTester tester) =>
      tapAndSettle(tester, find.byTooltip('Settings'));

  Future<void> turnOn(WidgetTester tester) async {
    await openSettings(tester);
    await tapAndSettle(tester, find.text('App lock'));
    await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
    await tester.enterText(find.bySemanticsLabel('Type it again'), _passphrase);
    await tapAndSettle(tester, find.text('Turn on'));
  }

  bool switchOn(WidgetTester tester) => tester
      .getSemantics(find.text('App lock'))
      .flagsCollection
      .isToggled
      .toBoolOrNull()!;

  testWidgets('App lock turns on from Settings', (tester) async {
    final gate = await pumpGate(tester);

    await turnOn(tester);

    expect(gate.lock.enabled, isTrue);
    expect(find.text('Settings'), findsOneWidget);
    expect(switchOn(tester), isTrue);
    expect(find.text('Lock now'), findsOneWidget);
  });

  testWidgets('a short or mistyped passphrase is caught with a fix', (
    tester,
  ) async {
    final gate = await pumpGate(tester);
    await openSettings(tester);
    await tapAndSettle(tester, find.text('App lock'));

    await tester.enterText(find.bySemanticsLabel('Passphrase'), 'too short');
    await tapAndSettle(tester, find.text('Turn on'));
    expect(
      find.text(
        'Use at least 12 characters. A few words in a row are easy to '
        'remember.',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
    await tester.enterText(find.bySemanticsLabel('Type it again'), 'other');
    await tapAndSettle(tester, find.text('Turn on'));
    expect(
      find.text('The two passphrases differ. Type the same one twice.'),
      findsOneWidget,
    );
    expect(gate.lock.enabled, isFalse);
  });

  testWidgets('Lock now hides every wallet behind the lock screen', (
    tester,
  ) async {
    await pumpGate(tester);
    await turnOn(tester);

    await tapAndSettle(tester, find.text('Lock now'));

    expect(find.text('Lumen is locked'), findsOneWidget);
    expect(find.text('Home node'), findsNothing);
    expect(find.textContaining('21,000'), findsNothing);
  });

  testWidgets('the right passphrase opens Lumen, a wrong one says so', (
    tester,
  ) async {
    final haptics = watchHaptics(tester);
    await pumpGate(tester, locked: true);
    expect(find.text('Lumen is locked'), findsOneWidget);

    await tester.enterText(
      find.bySemanticsLabel('Passphrase'),
      'wrong horse battery',
    );
    await tapAndSettle(tester, find.text('Unlock'));
    expect(
      find.text('This is not your passphrase. Check it and try again.'),
      findsOneWidget,
    );
    expect(haptics, ['HapticFeedbackType.errorNotification']);

    await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
    await tapAndSettle(tester, find.text('Unlock'));
    expect(find.text('Lumen is locked'), findsNothing);
    expect(find.text('Home node'), findsOneWidget);
  });

  testWidgets('an empty passphrase is not counted as a try', (tester) async {
    final store = MemoryLockStore();
    await pumpGate(tester, locked: true, lockStore: store);

    await tapAndSettle(tester, find.text('Unlock'));

    expect(find.text('Enter your passphrase.'), findsOneWidget);
    expect(store.record!.failures, 0);
  });

  testWidgets('repeated wrong passphrases say how long to wait', (
    tester,
  ) async {
    final store = MemoryLockStore();
    final gate = await pumpGate(tester, locked: true, lockStore: store);
    store.record = store.record!.copyWith(
      failures: AppLock.freeAttempts,
      retryAt: () => clock.now().add(const Duration(seconds: 90)),
    );
    await tester.runAsync(gate.lock.load);

    await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
    await tapAndSettle(tester, find.text('Unlock'));

    expect(
      find.text('Too many wrong passphrases. Try again in 2 minutes.'),
      findsOneWidget,
    );
    expect(find.text('Lumen is locked'), findsOneWidget);
  });

  testWidgets('a forgotten passphrase resets Lumen to its welcome', (
    tester,
  ) async {
    final gate = await pumpGate(tester, locked: true);

    await tapAndSettle(tester, find.text('Forgot your passphrase?'));
    expect(find.text('Reset Lumen?'), findsOneWidget);
    await tapAndSettle(tester, find.text('Reset'));
    await settle(tester);

    expect(gate.lock.enabled, isFalse);
    expect(find.text('Lumen is locked'), findsNothing);
  });

  testWidgets('turning App lock off needs the passphrase', (tester) async {
    final gate = await pumpGate(tester);
    await turnOn(tester);

    await tapAndSettle(tester, find.text('App lock'));
    expect(find.text('Turn off App lock?'), findsOneWidget);
    await tester.enterText(
      find.bySemanticsLabel('Passphrase'),
      'wrong horse battery',
    );
    await tapAndSettle(tester, find.text('Turn off'));
    expect(
      find.text('This is not your passphrase. Check it and try again.'),
      findsOneWidget,
    );

    await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
    await tapAndSettle(tester, find.text('Turn off'));
    expect(gate.lock.enabled, isFalse);
    expect(switchOn(tester), isFalse);
    expect(find.text('Lock now'), findsNothing);
  });

  String? Function() watchClipboard(WidgetTester tester) {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return () => copied;
  }

  Future<void> openCopyConnection(WidgetTester tester) async {
    await tapAndSettle(tester, find.text('Home node'));
    await tapAndSettle(tester, find.byTooltip('Home node options'));
    await tapAndSettle(tester, find.text('Copy connection string'));
    expect(find.text('Copy the connection string?'), findsOneWidget);
  }

  testWidgets('the connection string is copied after a warning', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final copied = watchClipboard(tester);
    await pumpGate(tester);
    await openCopyConnection(tester);
    expect(find.bySemanticsLabel('Passphrase'), findsNothing);

    await tapAndSettle(tester, find.text('Cancel'));
    expect(copied(), isNull);

    await tapAndSettle(tester, find.byTooltip('Home node options'));
    await tapAndSettle(tester, find.text('Copy connection string'));
    await tapAndSettle(tester, find.text('Copy'));
    expect(copied(), 'nostr+walletconnect://wallet?secret=fake');
    expect(find.text('Connection string copied.'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.widgetWithText(TextButton, 'Done'))
          .flagsCollection
          .isFocused
          .toBoolOrNull(),
      isTrue,
    );

    await tapAndSettle(tester, find.text('Done'));
    expect(find.text('Copy the connection string?'), findsNothing);
    handle.dispose();
  });

  testWidgets('with App lock on, copying the connection string needs the '
      'passphrase', (tester) async {
    final copied = watchClipboard(tester);
    await pumpGate(tester, locked: true);
    await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
    await tapAndSettle(tester, find.text('Unlock'));
    await openCopyConnection(tester);

    await tapAndSettle(tester, find.text('Copy'));
    expect(find.text('Enter your passphrase.'), findsOneWidget);

    await tester.enterText(
      find.bySemanticsLabel('Passphrase'),
      'wrong horse battery',
    );
    await tapAndSettle(tester, find.text('Copy'));
    expect(
      find.text('This is not your passphrase. Check it and try again.'),
      findsOneWidget,
    );
    expect(copied(), isNull);

    await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
    await tapAndSettle(tester, find.text('Copy'));
    expect(copied(), 'nostr+walletconnect://wallet?secret=fake');
    expect(find.text('Connection string copied.'), findsOneWidget);
  });

  testWidgets('the passphrase can be changed with the current one', (
    tester,
  ) async {
    final gate = await pumpGate(tester);
    await turnOn(tester);
    const next = 'a much longer passphrase';

    await tapAndSettle(tester, find.text('Change passphrase'));
    await tester.enterText(
      find.bySemanticsLabel('Current passphrase'),
      _passphrase,
    );
    await tester.enterText(find.bySemanticsLabel('New passphrase'), next);
    await tester.enterText(find.bySemanticsLabel('Type it again'), next);
    await tapAndSettle(tester, find.text('Save'));

    expect(find.text('Settings'), findsOneWidget);
    await tester.runAsync(gate.lockNow);
    expect(
      await tester.runAsync(() => gate.unlock(_passphrase)),
      PassphraseCheck.wrong,
    );
    expect(
      await tester.runAsync(() => gate.unlock(next)),
      PassphraseCheck.correct,
    );
  });

  testWidgets('the passphrase stays hidden until the user shows it', (
    tester,
  ) async {
    await pumpGate(tester, locked: true);
    TextField field() => tester.widget<TextField>(find.byType(TextField));

    expect(field().obscureText, isTrue);
    await tapAndSettle(tester, find.byTooltip('Show passphrase'));
    expect(field().obscureText, isFalse);
    expect(find.byTooltip('Hide passphrase'), findsOneWidget);
  });

  testWidgets('the desktop sidebar offers Settings, and Lock now once on', (
    tester,
  ) async {
    await pumpGate(tester, size: desktopSize);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Lock now'), findsNothing);

    await tapAndSettle(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('App lock'));
    await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
    await tester.enterText(find.bySemanticsLabel('Type it again'), _passphrase);
    await tapAndSettle(tester, find.text('Turn on'));

    expect(find.text('Lock now'), findsNWidgets(2));
    expect(
      find.bySemanticsLabel('Lock now, Keyboard shortcut: ⌘L'),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('Lock now').first);
    expect(find.text('Lumen is locked'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets(
    'Cmd+L or Ctrl+L locks Lumen once App lock is on',
    (tester) async {
      final modifier = defaultTargetPlatform == TargetPlatform.macOS
          ? LogicalKeyboardKey.metaLeft
          : LogicalKeyboardKey.controlLeft;
      Future<void> pressLock() async {
        await tester.sendKeyDownEvent(modifier);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
        await tester.sendKeyUpEvent(modifier);
        await settle(tester);
      }

      final gate = await pumpGate(tester);
      await pressLock();
      expect(gate.lock.locked, isFalse);
      expect(find.text('Home node'), findsOneWidget);

      await turnOn(tester);
      await pressLock();

      expect(find.text('Lumen is locked'), findsOneWidget);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.macOS,
      TargetPlatform.windows,
    }),
  );

  Future<void> expectGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final brightness in Brightness.values) {
    for (final (name, size) in [
      ('phone', phoneSize),
      ('desktop', desktopSize),
    ]) {
      testWidgets(
        'lock screens meet the guidelines, $name, ${brightness.name}',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpGate(tester, size: size, brightness: brightness);
          await openSettingsAt(tester, size);
          await expectGuidelines(tester);

          await tapAndSettle(tester, find.text('App lock'));
          await expectGuidelines(tester);
          await tester.enterText(
            find.bySemanticsLabel('Passphrase'),
            _passphrase,
          );
          await tester.enterText(
            find.bySemanticsLabel('Type it again'),
            _passphrase,
          );
          await tapAndSettle(tester, find.text('Turn on'));
          await expectGuidelines(tester);

          await tapAndSettle(tester, find.text('Lock now').last);
          await expectGuidelines(tester);
          handle.dispose();
        },
        variant: _platformFor(size),
      );
    }
  }

  for (final (name, size) in [('phone', phoneSize), ('desktop', desktopSize)]) {
    testWidgets('lock screens lay out at 200% text, $name', (tester) async {
      await pumpGate(tester, size: size, textScale: 2);
      await openSettingsAt(tester, size);
      expect(tester.takeException(), isNull, reason: 'settings');

      await tapAndSettle(tester, find.text('App lock'));
      expect(tester.takeException(), isNull, reason: 'turn on');
      await tester.enterText(find.bySemanticsLabel('Passphrase'), _passphrase);
      await tester.enterText(
        find.bySemanticsLabel('Type it again'),
        _passphrase,
      );
      await tapAndSettle(tester, find.text('Turn on'));

      await tapAndSettle(tester, find.text('Lock now').last);
      expect(tester.takeException(), isNull, reason: 'lock screen');
      await tapAndSettle(tester, find.text('Forgot your passphrase?'));
      expect(tester.takeException(), isNull, reason: 'reset dialog');
    }, variant: _platformFor(size));
  }

  testWidgets('the lock screen title names the route and takes focus', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpGate(tester, locked: true);

    final title = tester.getSemantics(find.text('Lumen is locked'));
    expect(title.flagsCollection.isHeader, isTrue);
    expect(title.flagsCollection.namesRoute, isTrue);
    expect(title.flagsCollection.isFocused.toBoolOrNull(), isTrue);
    handle.dispose();
  });

  testWidgets('the App lock row reads as one switch with its hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpGate(tester);
    await openSettings(tester);

    expect(
      tester.getSemantics(find.text('App lock')),
      matchesSemantics(
        label:
            'App lock\nAsks for your passphrase when Lumen opens, and '
            'encrypts your wallets with it',
        hasToggledState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });
}

Future<void> openSettingsAt(WidgetTester tester, Size size) async {
  final button = size == desktopSize
      ? find.text('Settings')
      : find.byTooltip('Settings');
  await tester.tap(button);
  await tester.pumpAndSettle();
}

TestVariant<Object?> _platformFor(Size size) => size == desktopSize
    ? TargetPlatformVariant.only(TargetPlatform.macOS)
    : const DefaultTestVariant();
