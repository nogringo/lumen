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
  String get grantChecking => 'Checking what this connection allows';

  @override
  String get grantUnreachable =>
      'Lumen could not reach this wallet to check what the connection allows. You can still connect it.';

  @override
  String get grantCan => 'This connection can';

  @override
  String get grantCannot => 'This connection cannot';

  @override
  String get grantAllowed => 'Allowed';

  @override
  String get grantDenied => 'Not allowed';

  @override
  String get abilityReadBalance => 'See the balance';

  @override
  String get abilityReceive => 'Create invoices';

  @override
  String get abilityPay => 'Pay invoices';

  @override
  String get abilityListTransactions => 'List transactions';

  @override
  String budgetPerDay(String amount) {
    return 'Up to $amount sats a day';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'Up to $amount sats a week';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'Up to $amount sats a month';
  }

  @override
  String budgetPerYear(String amount) {
    return 'Up to $amount sats a year';
  }

  @override
  String budgetTotal(String amount) {
    return 'Up to $amount sats in total';
  }

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

  @override
  String get send => 'Send';

  @override
  String get sendTo => 'To';

  @override
  String get sendToHint => 'Lightning invoice or Lightning address';

  @override
  String get paste => 'Paste';

  @override
  String get payFrom => 'Pay from';

  @override
  String get chooseWalletThatPays => 'Choose the wallet that pays';

  @override
  String get amountSetByInvoice => 'Amount set by the invoice';

  @override
  String get reviewPayment => 'Review';

  @override
  String get checkingPayment => 'Checking';

  @override
  String get youAreSending => 'You are sending';

  @override
  String get detailTo => 'To';

  @override
  String get detailNote => 'Note';

  @override
  String get detailFrom => 'From';

  @override
  String get detailNetwork => 'Network';

  @override
  String get detailFeePaid => 'Fee paid';

  @override
  String get lightningInvoice => 'Lightning invoice';

  @override
  String sendAmount(String amount) {
    return 'Send $amount sats';
  }

  @override
  String get sendingPayment => 'Sending';

  @override
  String get editPayment => 'Edit payment';

  @override
  String get paymentSent => 'Payment sent';

  @override
  String sentTo(String label) {
    return 'To $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Payment sent: $amount sats from $name';
  }

  @override
  String get errorToEmpty =>
      'Paste a Lightning invoice or a Lightning address.';

  @override
  String get errorToUnrecognized =>
      'This is not a Lightning invoice or address. An invoice starts with lnbc, an address looks like name@example.com.';

  @override
  String get errorInvoiceNoAmount =>
      'This invoice leaves the amount open, which Lumen cannot pay yet. Ask the recipient for an invoice with an amount.';

  @override
  String get errorInvoiceExpired =>
      'This invoice expired. Ask the recipient for a new one.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label accepts from $min to $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen could not reach $label. Check the address and your connection, then try again.';
  }

  @override
  String recipientRefused(String label) {
    return '$label cannot receive payments right now. Check the address with the recipient.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label sent an invoice for another amount, so Lumen did not pay it.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name holds $balance sats, not enough for this payment. Pay from another wallet or lower the amount.';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen could not reach $name, so nothing was sent. Check that it is online, then try again.';
  }

  @override
  String get sendNoPermission =>
      'This connection cannot pay. In your wallet, create a new connection that allows payments.';

  @override
  String sendInsufficientBalance(String name) {
    return '$name does not hold enough sats for this payment and its fee. Pay from another wallet or lower the amount.';
  }

  @override
  String get sendBudgetExceeded =>
      'This connection has used up its spending budget. Raise it in your wallet\'s NWC settings, or pay from another wallet.';

  @override
  String get sendFailed =>
      'The payment did not go through, often for lack of a route to the recipient. Try again later, or pay from another wallet.';

  @override
  String sendUnconfirmed(String name) {
    return '$name did not confirm the payment in time. It may still go through: check its recent activity before you try again.';
  }

  @override
  String get settings => 'Settings';

  @override
  String get security => 'Security';

  @override
  String get general => 'General';

  @override
  String get language => 'Language';

  @override
  String get deviceLanguage => 'Device language';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockHint =>
      'Asks for your passphrase when Lumen opens, and encrypts your wallets with it';

  @override
  String get changePassphrase => 'Change passphrase';

  @override
  String get lockNow => 'Lock now';

  @override
  String keyboardShortcut(String keys) {
    return 'Keyboard shortcut: $keys';
  }

  @override
  String get turnOnAppLock => 'Turn on App lock';

  @override
  String get passphraseLead =>
      'Choose a passphrase of at least 12 characters. A few unrelated words are long and easy to remember.';

  @override
  String get passphraseWarning =>
      'If you forget it, the only way back in is to reset Lumen, which removes your wallets from this device. Your funds stay with your wallet services.';

  @override
  String get passphraseLabel => 'Passphrase';

  @override
  String get newPassphraseLabel => 'New passphrase';

  @override
  String get confirmPassphraseLabel => 'Type it again';

  @override
  String get currentPassphraseLabel => 'Current passphrase';

  @override
  String get showPassphrase => 'Show passphrase';

  @override
  String get hidePassphrase => 'Hide passphrase';

  @override
  String get turnOn => 'Turn on';

  @override
  String get errorPassphraseShort =>
      'Use at least 12 characters. A few words in a row are easy to remember.';

  @override
  String get errorPassphraseMismatch =>
      'The two passphrases differ. Type the same one twice.';

  @override
  String get errorPassphraseWrong =>
      'This is not your passphrase. Check it and try again.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Too many wrong passphrases. Try again in $count seconds.',
      one: 'Too many wrong passphrases. Try again in 1 second.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Too many wrong passphrases. Try again in $count minutes.',
      one: 'Too many wrong passphrases. Try again in 1 minute.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'Lumen could not save your passphrase. Try again.';

  @override
  String get turnOffTitle => 'Turn off App lock?';

  @override
  String get turnOffBody =>
      'Lumen will open without a passphrase, and your wallets will no longer be encrypted.';

  @override
  String get turnOff => 'Turn off';

  @override
  String get lockedTitle => 'Lumen is locked';

  @override
  String get lockedLead => 'Enter your passphrase to open your wallets.';

  @override
  String get unlock => 'Unlock';

  @override
  String get forgotPassphrase => 'Forgot your passphrase?';

  @override
  String get resetTitle => 'Reset Lumen?';

  @override
  String get resetBody =>
      'Lumen removes your wallets and App lock from this device. Your funds stay with your wallet services: add each wallet again with its connection string.';

  @override
  String get reset => 'Reset';

  @override
  String get errorPassphraseEmpty => 'Enter your passphrase.';
}
