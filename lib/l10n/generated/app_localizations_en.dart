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
  String get balanceNoPermission =>
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
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wallets are not counted: their balances are unavailable.',
      one: '1 wallet is not counted: its balance is unavailable.',
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

  @override
  String get refreshBalances => 'Refresh balances';

  @override
  String get refreshBalance => 'Refresh balance';

  @override
  String get receive => 'Receive';

  @override
  String get receiveInto => 'Into';

  @override
  String get chooseWallet => 'Choose the wallet that receives';

  @override
  String get amountLabel => 'Amount in sats';

  @override
  String get createInvoice => 'Create invoice';

  @override
  String get creatingInvoice => 'Creating invoice';

  @override
  String get errorAmountEmpty => 'Enter an amount of at least 1 sat.';

  @override
  String get receiveUnreachable =>
      'Lumen could not get an invoice from this wallet. Check that it is online, then try again.';

  @override
  String get receiveNoPermission =>
      'This connection cannot create invoices. In your wallet, create a new connection that allows receiving payments.';

  @override
  String invoiceQrLabel(String amount) {
    return 'QR code of the Lightning invoice for $amount sats. The invoice text is below, with a copy button.';
  }

  @override
  String invoiceText(String text) {
    return 'Invoice $text';
  }

  @override
  String get editAmount => 'Edit amount';

  @override
  String get copyInvoice => 'Copy invoice';

  @override
  String get invoiceCopied => 'Invoice copied';

  @override
  String get shareInvoice => 'Share invoice';

  @override
  String get waitingForPayment => 'Waiting for payment';

  @override
  String get expiresSoon => 'Expires in less than a minute';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Expires in $minutes minutes',
      one: 'Expires in 1 minute',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Expires in $hours hours',
      one: 'Expires in 1 hour',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'This invoice expired. Create a new one to receive this payment.';

  @override
  String get newInvoice => 'New invoice';

  @override
  String get paymentReceived => 'Payment received';

  @override
  String receivedInto(String name) {
    return 'Into $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Payment received: $amount sats into $name';
  }

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get activityLoading => 'Loading activity';

  @override
  String get noActivity => 'No payments yet.';

  @override
  String get activityUnreachable =>
      'Lumen could not load the activity of this wallet.';

  @override
  String get activityNoPermission =>
      'This connection cannot list transactions. In your wallet, create a new connection that allows listing transactions.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Activity from $count wallets is not shown: it could not be loaded.',
      one: 'Activity from 1 wallet is not shown: it could not be loaded.',
    );
    return '$_temp0';
  }

  @override
  String get transactionReceived => 'Received';

  @override
  String get transactionSent => 'Sent';

  @override
  String amountReceived(String amount) {
    return 'received $amount sats';
  }

  @override
  String amountSent(String amount) {
    return 'sent $amount sats';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet, $when';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String get columnDescription => 'Description';

  @override
  String get columnWallet => 'Wallet';

  @override
  String get columnDate => 'Date';

  @override
  String get columnAmount => 'Amount';
}
