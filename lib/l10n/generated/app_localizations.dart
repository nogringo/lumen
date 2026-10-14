import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('en'),
    Locale('fr'),
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

  /// Button label while Lumen checks the connection.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

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

  /// Error when the wallet does not answer over its relays.
  ///
  /// In en, this message translates to:
  /// **'Lumen could not reach this wallet. Check that it is online and that the connection is still active, then try again.'**
  String get errorUriUnreachable;

  /// Error when the connection lacks the permission to read the balance.
  ///
  /// In en, this message translates to:
  /// **'This connection cannot read the balance. In your wallet, create a new connection that allows reading the balance.'**
  String get errorUriNoBalance;

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
  /// **'{count, plural, =1{1 wallet could not be reached.} other{{count} wallets could not be reached.}}'**
  String walletsUnreachable(int count);

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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
