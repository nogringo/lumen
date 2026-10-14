// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tagline => 'Every way you hold bitcoin, in one place.';

  @override
  String get supportedWallets => 'Supported wallets';

  @override
  String get kindLightning => 'Lightning';

  @override
  String get kindEcash => 'Ecash';

  @override
  String get kindOnchain => 'On-chain';

  @override
  String get kindLiquid => 'Liquid';

  @override
  String get lightningViaNwc => 'Lightning via NWC';

  @override
  String get addAWallet => 'Add a wallet';

  @override
  String get add => 'Add';

  @override
  String get addWallet => 'Add wallet';

  @override
  String get back => 'Back';

  @override
  String get connectNwcTitle => 'Connect with NWC';

  @override
  String get connectNwcLead =>
      'Copy the connection string from your wallet\'s NWC settings.';

  @override
  String get connectionStringLabel => 'Connection string';

  @override
  String get connectionStringHint => 'Starts with nostr+walletconnect://';

  @override
  String get nameLabel => 'Name';

  @override
  String get connect => 'Connect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get errorUriEmpty =>
      'Paste the connection string from your wallet\'s NWC settings.';

  @override
  String get errorUriNotNwc =>
      'This is not an NWC connection string. It should start with nostr+walletconnect://';

  @override
  String get errorUriIncomplete =>
      'This connection string is incomplete. Copy it again from your wallet, in full.';

  @override
  String get errorUriDuplicate => 'This wallet is already in Lumen.';

  @override
  String get errorUriUnreachable =>
      'Lumen could not reach this wallet. Check that it is online and that the connection is still active, then try again.';

  @override
  String get errorUriNoBalance =>
      'This connection cannot read the balance. In your wallet, create a new connection that allows reading the balance.';

  @override
  String get errorNameEmpty => 'Give this wallet a name.';

  @override
  String get overview => 'Overview';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get wallets => 'Wallets';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'Loading balance';

  @override
  String get balanceUnavailable => 'Unavailable';

  @override
  String walletsUnreachable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wallets could not be reached.',
      one: '1 wallet could not be reached.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable => 'Lumen could not reach this wallet.';

  @override
  String get tryAgain => 'Try again';

  @override
  String walletOptions(String name) {
    return '$name options';
  }

  @override
  String get rename => 'Rename';

  @override
  String get remove => 'Remove';

  @override
  String get renameTitle => 'Rename wallet';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String removeTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeBody =>
      'Lumen forgets this connection. The wallet and its funds are not affected, and you can connect it again later.';
}
