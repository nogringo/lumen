import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Welcome screen subtitle under the Lumen wordmark.
  ///
  /// In en, this message translates to:
  /// **'Every way you hold bitcoin, in one place.'**
  String get tagline;

  /// Accessible name of the list of wallet types on the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Supported wallets'**
  String get supportedWallets;

  /// Wallet type: Lightning.
  ///
  /// In en, this message translates to:
  /// **'Lightning'**
  String get kindLightning;

  /// Wallet type: Cashu ecash.
  ///
  /// In en, this message translates to:
  /// **'Ecash'**
  String get kindEcash;

  /// Wallet type: Bitcoin on-chain.
  ///
  /// In en, this message translates to:
  /// **'On-chain'**
  String get kindOnchain;

  /// Wallet type: Liquid sidechain.
  ///
  /// In en, this message translates to:
  /// **'Liquid'**
  String get kindLiquid;

  /// Subtitle of a Lightning wallet connected with Nostr Wallet Connect.
  ///
  /// In en, this message translates to:
  /// **'Lightning via NWC'**
  String get lightningViaNwc;

  /// Main button of the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Add a wallet'**
  String get addAWallet;

  /// Short link next to the Wallets heading on Home.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Link in the desktop sidebar, and accessible name of the short Add link.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get addWallet;

  /// Tooltip and accessible name of the back button.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Title of the screen that adds a wallet with an NWC connection string.
  ///
  /// In en, this message translates to:
  /// **'Connect with NWC'**
  String get connectNwcTitle;

  /// Explanation under the NWC screen title.
  ///
  /// In en, this message translates to:
  /// **'Copy the connection string from your wallet\'s NWC settings.'**
  String get connectNwcLead;

  /// Label of the NWC connection string field.
  ///
  /// In en, this message translates to:
  /// **'Connection string'**
  String get connectionStringLabel;

  /// Hint under the connection string field. Keep nostr+walletconnect:// as is.
  ///
  /// In en, this message translates to:
  /// **'Starts with nostr+walletconnect://'**
  String get connectionStringHint;

  /// Label of the wallet name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Button that checks the connection string and saves the wallet.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Error when the connection string field is empty.
  ///
  /// In en, this message translates to:
  /// **'Paste the connection string from your wallet\'s NWC settings.'**
  String get errorUriEmpty;

  /// Error when the text is not an NWC connection string. Keep nostr+walletconnect:// as is.
  ///
  /// In en, this message translates to:
  /// **'This is not an NWC connection string. It should start with nostr+walletconnect://'**
  String get errorUriNotNwc;

  /// Error when the connection string misses its secret, relay or wallet key.
  ///
  /// In en, this message translates to:
  /// **'This connection string is incomplete. Copy it again from your wallet, in full.'**
  String get errorUriIncomplete;

  /// Error when this connection is already saved.
  ///
  /// In en, this message translates to:
  /// **'This wallet is already in Lumen.'**
  String get errorUriDuplicate;

  /// Shown in the permissions card while Lumen asks the wallet what the pasted connection allows.
  ///
  /// In en, this message translates to:
  /// **'Checking what this connection allows'**
  String get grantChecking;

  /// Shown in the permissions card when the wallet could not be reached before saving.
  ///
  /// In en, this message translates to:
  /// **'Lumen could not reach this wallet to check what the connection allows. You can still connect it.'**
  String get grantUnreachable;

  /// Heading of the list of what the NWC connection allows. Followed by items such as See the balance.
  ///
  /// In en, this message translates to:
  /// **'This connection can'**
  String get grantCan;

  /// Heading of the list of what the NWC connection does not allow. Followed by items such as Pay invoices.
  ///
  /// In en, this message translates to:
  /// **'This connection cannot'**
  String get grantCannot;

  /// Read by screen readers before an item the connection allows.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get grantAllowed;

  /// Read by screen readers before an item the connection does not allow.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get grantDenied;

  /// Item of the permissions card: the connection can read the wallet balance.
  ///
  /// In en, this message translates to:
  /// **'See the balance'**
  String get abilityReadBalance;

  /// Item of the permissions card: the connection can create Lightning invoices to receive.
  ///
  /// In en, this message translates to:
  /// **'Create invoices'**
  String get abilityReceive;

  /// Item of the permissions card: the connection can pay Lightning invoices.
  ///
  /// In en, this message translates to:
  /// **'Pay invoices'**
  String get abilityPay;

  /// Item of the permissions card: the connection can list past payments.
  ///
  /// In en, this message translates to:
  /// **'List transactions'**
  String get abilityListTransactions;

  /// Spending budget of the connection, renewed every day.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount} sats a day'**
  String budgetPerDay(String amount);

  /// Spending budget of the connection, renewed every week.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount} sats a week'**
  String budgetPerWeek(String amount);

  /// Spending budget of the connection, renewed every month.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount} sats a month'**
  String budgetPerMonth(String amount);

  /// Spending budget of the connection, renewed every year.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount} sats a year'**
  String budgetPerYear(String amount);

  /// Spending budget of the connection, never renewed.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount} sats in total'**
  String budgetTotal(String amount);

  /// Shown on a wallet screen when its connection lacks the permission to read the balance.
  ///
  /// In en, this message translates to:
  /// **'This connection cannot read the balance. In your wallet, create a new connection that allows reading the balance.'**
  String get balanceNoPermission;

  /// Error when the wallet name is empty.
  ///
  /// In en, this message translates to:
  /// **'Give this wallet a name.'**
  String get errorNameEmpty;

  /// Title of the desktop overview page and its sidebar entry.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Label above the sum of all wallet balances.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// Heading of the wallet list.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// Unit shown after an amount. Satoshis, usually left untranslated.
  ///
  /// In en, this message translates to:
  /// **'sats'**
  String get satsUnit;

  /// Amount with its unit, read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'{amount} sats'**
  String amountSats(String amount);

  /// Accessible label of the spinner shown while a balance loads.
  ///
  /// In en, this message translates to:
  /// **'Loading balance'**
  String get balanceLoading;

  /// Shown instead of a balance when the wallet could not be reached.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get balanceUnavailable;

  /// Note under the total balance when some wallets are left out of it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 wallet is not counted: its balance is unavailable.} other{{count} wallets are not counted: their balances are unavailable.}}'**
  String walletsNotCounted(int count);

  /// Shown on a wallet screen when its balance could not be read.
  ///
  /// In en, this message translates to:
  /// **'Lumen could not reach this wallet.'**
  String get walletUnreachable;

  /// Button that reloads a balance that failed.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Tooltip and accessible name of the wallet options menu button.
  ///
  /// In en, this message translates to:
  /// **'{name} options'**
  String walletOptions(String name);

  /// Menu item that renames a wallet.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Menu item and confirm button that remove a wallet from Lumen.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Title of the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename wallet'**
  String get renameTitle;

  /// Button that saves the new wallet name.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button that closes a dialog without changes.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title of the remove confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeTitle(String name);

  /// Body of the remove confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Lumen forgets this connection. The wallet and its funds are not affected, and you can connect it again later.'**
  String get removeBody;

  /// Accessibility action on the total balance that reloads every wallet balance.
  ///
  /// In en, this message translates to:
  /// **'Refresh balances'**
  String get refreshBalances;

  /// Accessibility action on a wallet balance that reloads it.
  ///
  /// In en, this message translates to:
  /// **'Refresh balance'**
  String get refreshBalance;

  /// Action that opens the receive flow, and title of that screen.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// Label above the wallet that will receive the payment.
  ///
  /// In en, this message translates to:
  /// **'Into'**
  String get receiveInto;

  /// Accessibility hint of the wallet picker on the receive screen.
  ///
  /// In en, this message translates to:
  /// **'Choose the wallet that receives'**
  String get chooseWallet;

  /// Label of the amount field.
  ///
  /// In en, this message translates to:
  /// **'Amount in sats'**
  String get amountLabel;

  /// Button that asks the wallet for a Lightning invoice.
  ///
  /// In en, this message translates to:
  /// **'Create invoice'**
  String get createInvoice;

  /// Button label while the wallet creates the invoice.
  ///
  /// In en, this message translates to:
  /// **'Creating invoice'**
  String get creatingInvoice;

  /// Error when the amount to receive is empty or zero.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount of at least 1 sat.'**
  String get errorAmountEmpty;

  /// Error when the wallet did not create the invoice.
  ///
  /// In en, this message translates to:
  /// **'Lumen could not get an invoice from this wallet. Check that it is online, then try again.'**
  String get receiveUnreachable;

  /// Error when the NWC connection lacks the permission to create invoices.
  ///
  /// In en, this message translates to:
  /// **'This connection cannot create invoices. In your wallet, create a new connection that allows receiving payments.'**
  String get receiveNoPermission;

  /// Accessible description of the invoice QR code.
  ///
  /// In en, this message translates to:
  /// **'QR code of the Lightning invoice for {amount} sats. The invoice text is below, with a copy button.'**
  String invoiceQrLabel(String amount);

  /// Accessible label of the shortened invoice text.
  ///
  /// In en, this message translates to:
  /// **'Invoice {text}'**
  String invoiceText(String text);

  /// Link that goes back to the amount field.
  ///
  /// In en, this message translates to:
  /// **'Edit amount'**
  String get editAmount;

  /// Tooltip and accessible name of the copy button.
  ///
  /// In en, this message translates to:
  /// **'Copy invoice'**
  String get copyInvoice;

  /// Announced to screen readers after copying the invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice copied'**
  String get invoiceCopied;

  /// Tooltip and accessible name of the share button.
  ///
  /// In en, this message translates to:
  /// **'Share invoice'**
  String get shareInvoice;

  /// Status under the invoice until it is paid.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get waitingForPayment;

  /// Time left on an invoice, under one minute.
  ///
  /// In en, this message translates to:
  /// **'Expires in less than a minute'**
  String get expiresSoon;

  /// Time left on an invoice.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{Expires in 1 minute} other{Expires in {minutes} minutes}}'**
  String expiresInMinutes(int minutes);

  /// Time left on an invoice.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{Expires in 1 hour} other{Expires in {hours} hours}}'**
  String expiresInHours(int hours);

  /// Shown when the invoice can no longer be paid.
  ///
  /// In en, this message translates to:
  /// **'This invoice expired. Create a new one to receive this payment.'**
  String get invoiceExpired;

  /// Button that replaces an expired invoice.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get newInvoice;

  /// Title shown once the invoice is paid.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get paymentReceived;

  /// Wallet that received the payment, under the amount.
  ///
  /// In en, this message translates to:
  /// **'Into {name}'**
  String receivedInto(String name);

  /// Announced to screen readers when the invoice is paid.
  ///
  /// In en, this message translates to:
  /// **'Payment received: {amount} sats into {name}'**
  String receivedAnnouncement(String amount, String name);

  /// Button that closes the receive flow after a payment.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Tooltip and accessible name of the dialog close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Heading of the latest transactions on Home and on a wallet screen.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// Accessible label of the spinner shown while transactions load.
  ///
  /// In en, this message translates to:
  /// **'Loading activity'**
  String get activityLoading;

  /// Shown under Recent activity when the wallets have no transactions.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get noActivity;

  /// Shown on a wallet screen when its transactions could not be read.
  ///
  /// In en, this message translates to:
  /// **'Lumen could not load the activity of this wallet.'**
  String get activityUnreachable;

  /// Shown on a wallet screen when its connection lacks the permission to list transactions.
  ///
  /// In en, this message translates to:
  /// **'This connection cannot list transactions. In your wallet, create a new connection that allows listing transactions.'**
  String get activityNoPermission;

  /// Note under Recent activity on Home when some wallets are left out of it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Activity from 1 wallet is not shown: it could not be loaded.} other{Activity from {count} wallets is not shown: it could not be loaded.}}'**
  String activityNotShown(int count);

  /// Title of an incoming payment that has no description.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get transactionReceived;

  /// Title of an outgoing payment that has no description.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get transactionSent;

  /// Incoming amount read by screen readers instead of +amount.
  ///
  /// In en, this message translates to:
  /// **'received {amount} sats'**
  String amountReceived(String amount);

  /// Outgoing amount read by screen readers instead of -amount.
  ///
  /// In en, this message translates to:
  /// **'sent {amount} sats'**
  String amountSent(String amount);

  /// Under a payment on Home: the wallet it went through, then when.
  ///
  /// In en, this message translates to:
  /// **'{wallet}, {when}'**
  String transactionWalletWhen(String wallet, String when);

  /// When a payment happened, less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// When a payment happened, less than an hour ago.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// When a payment happened, earlier today.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String hoursAgo(int hours);

  /// When a payment happened, the day before today.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Column header of the activity table on desktop.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get columnDescription;

  /// Column header of the activity table on desktop.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get columnWallet;

  /// Column header of the activity table on desktop.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get columnDate;

  /// Column header of the activity table on desktop.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get columnAmount;

  /// Action that opens the send flow, and title of that screen.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Label of the field with the invoice or address to pay.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get sendTo;

  /// Hint under the To field.
  ///
  /// In en, this message translates to:
  /// **'Lightning invoice or Lightning address'**
  String get sendToHint;

  /// Button that pastes the clipboard into the To field.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// Label above the wallet that pays.
  ///
  /// In en, this message translates to:
  /// **'Pay from'**
  String get payFrom;

  /// Accessibility hint of the wallet picker on the send screen.
  ///
  /// In en, this message translates to:
  /// **'Choose the wallet that pays'**
  String get chooseWalletThatPays;

  /// Label above the amount of a pasted invoice, which cannot be changed.
  ///
  /// In en, this message translates to:
  /// **'Amount set by the invoice'**
  String get amountSetByInvoice;

  /// Button that checks the payment and shows it before sending.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewPayment;

  /// Button label while Lumen checks the recipient.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get checkingPayment;

  /// Heading above the amount on the review step.
  ///
  /// In en, this message translates to:
  /// **'You are sending'**
  String get youAreSending;

  /// Row label: who receives the payment.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get detailTo;

  /// Row label: the invoice description.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get detailNote;

  /// Row label: the wallet that pays.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get detailFrom;

  /// Row label: the network the payment uses.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get detailNetwork;

  /// Row label: the routing fee the payment cost.
  ///
  /// In en, this message translates to:
  /// **'Fee paid'**
  String get detailFeePaid;

  /// Read by screen readers instead of a shortened invoice.
  ///
  /// In en, this message translates to:
  /// **'Lightning invoice'**
  String get lightningInvoice;

  /// Button that sends the payment.
  ///
  /// In en, this message translates to:
  /// **'Send {amount} sats'**
  String sendAmount(String amount);

  /// Button label while the wallet pays.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get sendingPayment;

  /// Button that goes back from the review step to the form.
  ///
  /// In en, this message translates to:
  /// **'Edit payment'**
  String get editPayment;

  /// Title shown once the payment went through.
  ///
  /// In en, this message translates to:
  /// **'Payment sent'**
  String get paymentSent;

  /// Who received the payment, under the amount.
  ///
  /// In en, this message translates to:
  /// **'To {label}'**
  String sentTo(String label);

  /// Announced to screen readers when the payment went through.
  ///
  /// In en, this message translates to:
  /// **'Payment sent: {amount} sats from {name}'**
  String sentAnnouncement(String amount, String name);

  /// Error when the To field is empty.
  ///
  /// In en, this message translates to:
  /// **'Paste a Lightning invoice or a Lightning address.'**
  String get errorToEmpty;

  /// Error when the To field holds something Lumen cannot pay. Keep lnbc as is.
  ///
  /// In en, this message translates to:
  /// **'This is not a Lightning invoice or address. An invoice starts with lnbc, an address looks like name@example.com.'**
  String get errorToUnrecognized;

  /// Error for an invoice without amount.
  ///
  /// In en, this message translates to:
  /// **'This invoice leaves the amount open, which Lumen cannot pay yet. Ask the recipient for an invoice with an amount.'**
  String get errorInvoiceNoAmount;

  /// Error for an expired invoice.
  ///
  /// In en, this message translates to:
  /// **'This invoice expired. Ask the recipient for a new one.'**
  String get errorInvoiceExpired;

  /// Error when the amount is outside what the Lightning address accepts.
  ///
  /// In en, this message translates to:
  /// **'{label} accepts from {min} to {max} sats.'**
  String errorAmountRange(String label, String min, String max);

  /// Error when the Lightning address service did not answer.
  ///
  /// In en, this message translates to:
  /// **'Lumen could not reach {label}. Check the address and your connection, then try again.'**
  String recipientUnreachable(String label);

  /// Error when the Lightning address service refused the payment.
  ///
  /// In en, this message translates to:
  /// **'{label} cannot receive payments right now. Check the address with the recipient.'**
  String recipientRefused(String label);

  /// Error when the Lightning address service sent a wrong invoice.
  ///
  /// In en, this message translates to:
  /// **'{label} sent an invoice for another amount, so Lumen did not pay it.'**
  String recipientWrongInvoice(String label);

  /// Error when the paying wallet's known balance is below the amount.
  ///
  /// In en, this message translates to:
  /// **'{name} holds {balance} sats, not enough for this payment. Pay from another wallet or lower the amount.'**
  String notEnoughSats(String name, String balance);

  /// Error when the paying wallet did not answer before the payment.
  ///
  /// In en, this message translates to:
  /// **'Lumen could not reach {name}, so nothing was sent. Check that it is online, then try again.'**
  String sendUnreachable(String name);

  /// Error when the NWC connection lacks the permission to pay invoices.
  ///
  /// In en, this message translates to:
  /// **'This connection cannot pay. In your wallet, create a new connection that allows payments.'**
  String get sendNoPermission;

  /// Error when the wallet reports an insufficient balance.
  ///
  /// In en, this message translates to:
  /// **'{name} does not hold enough sats for this payment and its fee. Pay from another wallet or lower the amount.'**
  String sendInsufficientBalance(String name);

  /// Error when the NWC connection's budget is used up.
  ///
  /// In en, this message translates to:
  /// **'This connection has used up its spending budget. Raise it in your wallet\'s NWC settings, or pay from another wallet.'**
  String get sendBudgetExceeded;

  /// Error when the wallet tried and the payment failed.
  ///
  /// In en, this message translates to:
  /// **'The payment did not go through, often for lack of a route to the recipient. Try again later, or pay from another wallet.'**
  String get sendFailed;

  /// Shown when the wallet did not answer after the payment was sent.
  ///
  /// In en, this message translates to:
  /// **'{name} did not confirm the payment in time. It may still go through: check its recent activity before you try again.'**
  String sendUnconfirmed(String name);

  /// Title of the Settings screen, and label of the button that opens it.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Group title in Settings.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Group title in Settings, above Language.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Settings row, and title of the dialog that picks the language of Lumen.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language choice that follows the language of the phone or computer.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get deviceLanguage;

  /// Settings switch that asks for a passphrase when Lumen opens.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// Explanation under the App lock switch.
  ///
  /// In en, this message translates to:
  /// **'Asks for your passphrase when Lumen opens, and encrypts your wallets with it'**
  String get appLockHint;

  /// Settings row, and title of the screen that changes the App lock passphrase.
  ///
  /// In en, this message translates to:
  /// **'Change passphrase'**
  String get changePassphrase;

  /// Button that locks Lumen at once.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get lockNow;

  /// Read by screen readers after a command that has a keyboard shortcut. keys is the key combination, like Ctrl+L.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcut: {keys}'**
  String keyboardShortcut(String keys);

  /// Title of the screen that sets the App lock passphrase.
  ///
  /// In en, this message translates to:
  /// **'Turn on App lock'**
  String get turnOnAppLock;

  /// Explanation at the top of the screen that sets the passphrase.
  ///
  /// In en, this message translates to:
  /// **'Choose a passphrase of at least 12 characters. A few unrelated words are long and easy to remember.'**
  String get passphraseLead;

  /// Warning on the screen that sets the passphrase.
  ///
  /// In en, this message translates to:
  /// **'If you forget it, the only way back in is to reset Lumen, which removes your wallets from this device. Your funds stay with your wallet services.'**
  String get passphraseWarning;

  /// Label of the passphrase field.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get passphraseLabel;

  /// Label of the field for the new passphrase.
  ///
  /// In en, this message translates to:
  /// **'New passphrase'**
  String get newPassphraseLabel;

  /// Label of the field that confirms the new passphrase.
  ///
  /// In en, this message translates to:
  /// **'Type it again'**
  String get confirmPassphraseLabel;

  /// Label of the field for the passphrase in use.
  ///
  /// In en, this message translates to:
  /// **'Current passphrase'**
  String get currentPassphraseLabel;

  /// Tooltip of the button that reveals a passphrase field.
  ///
  /// In en, this message translates to:
  /// **'Show passphrase'**
  String get showPassphrase;

  /// Tooltip of the button that hides a passphrase field again.
  ///
  /// In en, this message translates to:
  /// **'Hide passphrase'**
  String get hidePassphrase;

  /// Button that sets the passphrase and turns App lock on.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// Error under a new passphrase that is too short.
  ///
  /// In en, this message translates to:
  /// **'Use at least 12 characters. A few words in a row are easy to remember.'**
  String get errorPassphraseShort;

  /// Error under the confirmation field.
  ///
  /// In en, this message translates to:
  /// **'The two passphrases differ. Type the same one twice.'**
  String get errorPassphraseMismatch;

  /// Error under a passphrase field when the passphrase does not match.
  ///
  /// In en, this message translates to:
  /// **'This is not your passphrase. Check it and try again.'**
  String get errorPassphraseWrong;

  /// Error after repeated wrong passphrases, with the wait left under a minute.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Too many wrong passphrases. Try again in 1 second.} other{Too many wrong passphrases. Try again in {count} seconds.}}'**
  String errorWaitSeconds(int count);

  /// Error after repeated wrong passphrases, with the wait left in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Too many wrong passphrases. Try again in 1 minute.} other{Too many wrong passphrases. Try again in {count} minutes.}}'**
  String errorWaitMinutes(int count);

  /// Error when App lock could not be turned on or changed.
  ///
  /// In en, this message translates to:
  /// **'Lumen could not save your passphrase. Try again.'**
  String get errorLockSave;

  /// Title of the dialog that turns App lock off.
  ///
  /// In en, this message translates to:
  /// **'Turn off App lock?'**
  String get turnOffTitle;

  /// Explanation in the dialog that turns App lock off.
  ///
  /// In en, this message translates to:
  /// **'Lumen will open without a passphrase, and your wallets will no longer be encrypted.'**
  String get turnOffBody;

  /// Button that turns App lock off.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// Title of the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Lumen is locked'**
  String get lockedTitle;

  /// Explanation on the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Enter your passphrase to open your wallets.'**
  String get lockedLead;

  /// Button on the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Link on the lock screen that offers to reset Lumen.
  ///
  /// In en, this message translates to:
  /// **'Forgot your passphrase?'**
  String get forgotPassphrase;

  /// Title of the dialog that resets Lumen after a forgotten passphrase.
  ///
  /// In en, this message translates to:
  /// **'Reset Lumen?'**
  String get resetTitle;

  /// Explanation in the reset dialog.
  ///
  /// In en, this message translates to:
  /// **'Lumen removes your wallets and App lock from this device. Your funds stay with your wallet services: add each wallet again with its connection string.'**
  String get resetBody;

  /// Button that resets Lumen.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Error under the passphrase field when it is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your passphrase.'**
  String get errorPassphraseEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fi',
    'fr',
    'it',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
