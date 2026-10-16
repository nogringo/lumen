// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get tagline => 'Alle deine Bitcoin, an einem Ort.';

  @override
  String get supportedWallets => 'Unterstützte Wallets';

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
  String get addAWallet => 'Wallet hinzufügen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get addWallet => 'Wallet hinzufügen';

  @override
  String get back => 'Zurück';

  @override
  String get connectNwcTitle => 'Mit NWC verbinden';

  @override
  String get connectNwcLead =>
      'Kopiere den Verbindungsstring aus den NWC-Einstellungen deiner Wallet.';

  @override
  String get connectionStringLabel => 'Verbindungsstring';

  @override
  String get connectionStringHint => 'Beginnt mit nostr+walletconnect://';

  @override
  String get nameLabel => 'Name';

  @override
  String get connect => 'Verbinden';

  @override
  String get errorUriEmpty =>
      'Füge den Verbindungsstring aus den NWC-Einstellungen deiner Wallet ein.';

  @override
  String get errorUriNotNwc =>
      'Das ist kein NWC-Verbindungsstring. Er sollte mit nostr+walletconnect:// beginnen';

  @override
  String get errorUriIncomplete =>
      'Dieser Verbindungsstring ist unvollständig. Kopiere ihn noch einmal vollständig aus deiner Wallet.';

  @override
  String get errorUriDuplicate => 'Diese Wallet ist bereits in Lumen.';

  @override
  String get grantChecking => 'Prüfe, was diese Verbindung erlaubt';

  @override
  String get grantUnreachable =>
      'Lumen konnte diese Wallet nicht erreichen, um zu prüfen, was die Verbindung erlaubt. Du kannst sie trotzdem verbinden.';

  @override
  String get grantCan => 'Diese Verbindung kann';

  @override
  String get grantCannot => 'Diese Verbindung kann nicht';

  @override
  String get grantAllowed => 'Erlaubt';

  @override
  String get grantDenied => 'Nicht erlaubt';

  @override
  String get abilityReadBalance => 'Guthaben sehen';

  @override
  String get abilityReceive => 'Rechnungen erstellen';

  @override
  String get abilityPay => 'Rechnungen bezahlen';

  @override
  String get abilityListTransactions => 'Transaktionen auflisten';

  @override
  String budgetPerDay(String amount) {
    return 'Bis zu $amount sats pro Tag';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'Bis zu $amount sats pro Woche';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'Bis zu $amount sats pro Monat';
  }

  @override
  String budgetPerYear(String amount) {
    return 'Bis zu $amount sats pro Jahr';
  }

  @override
  String budgetTotal(String amount) {
    return 'Bis zu $amount sats insgesamt';
  }

  @override
  String get balanceNoPermission =>
      'Diese Verbindung kann das Guthaben nicht lesen. Erstelle in deiner Wallet eine neue Verbindung, die das Lesen des Guthabens erlaubt.';

  @override
  String get errorNameEmpty => 'Gib dieser Wallet einen Namen.';

  @override
  String get overview => 'Übersicht';

  @override
  String get totalBalance => 'Gesamtguthaben';

  @override
  String get wallets => 'Wallets';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'Guthaben wird geladen';

  @override
  String get balanceUnavailable => 'Nicht verfügbar';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Wallets sind nicht mitgezählt: ihr Guthaben ist nicht verfügbar.',
      one: '1 Wallet ist nicht mitgezählt: ihr Guthaben ist nicht verfügbar.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable => 'Lumen konnte diese Wallet nicht erreichen.';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get copyConnection => 'Verbindungsstring kopieren';

  @override
  String get copyConnectionTitle => 'Verbindungsstring kopieren?';

  @override
  String get copyConnectionBody =>
      'Wer ihn hat, kann diese Wallet wie Lumen nutzen und auch damit bezahlen, wenn die Verbindung das erlaubt. Füge ihn nur in eine App ein, der du vertraust.';

  @override
  String get copy => 'Kopieren';

  @override
  String get connectionCopied => 'Verbindungsstring kopiert.';

  @override
  String walletOptions(String name) {
    return 'Optionen für $name';
  }

  @override
  String get rename => 'Umbenennen';

  @override
  String get remove => 'Entfernen';

  @override
  String get renameTitle => 'Wallet umbenennen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String removeTitle(String name) {
    return '$name entfernen?';
  }

  @override
  String get removeBody =>
      'Lumen vergisst diese Verbindung. Die Wallet und ihr Guthaben bleiben unberührt, und du kannst sie später wieder verbinden.';

  @override
  String get refreshBalances => 'Guthaben aktualisieren';

  @override
  String get refreshBalance => 'Guthaben aktualisieren';

  @override
  String get receive => 'Empfangen';

  @override
  String get receiveInto => 'Auf';

  @override
  String get chooseWallet => 'Wähle die Wallet, die empfängt';

  @override
  String get amountLabel => 'Betrag in sats';

  @override
  String get createInvoice => 'Rechnung erstellen';

  @override
  String get creatingInvoice => 'Rechnung wird erstellt';

  @override
  String get errorAmountEmpty => 'Gib einen Betrag von mindestens 1 sat ein.';

  @override
  String get receiveUnreachable =>
      'Lumen konnte von dieser Wallet keine Rechnung erhalten. Prüfe, ob sie online ist, und versuche es dann erneut.';

  @override
  String get receiveNoPermission =>
      'Diese Verbindung kann keine Rechnungen erstellen. Erstelle in deiner Wallet eine neue Verbindung, die den Empfang von Zahlungen erlaubt.';

  @override
  String invoiceQrLabel(String amount) {
    return 'QR-Code der Lightning-Rechnung über $amount sats. Der Rechnungstext steht darunter, mit einer Schaltfläche zum Kopieren.';
  }

  @override
  String invoiceText(String text) {
    return 'Rechnung $text';
  }

  @override
  String get editAmount => 'Betrag ändern';

  @override
  String get copyInvoice => 'Rechnung kopieren';

  @override
  String get invoiceCopied => 'Rechnung kopiert';

  @override
  String get shareInvoice => 'Rechnung teilen';

  @override
  String get lightningAddress => 'Lightning-Adresse';

  @override
  String get copyAddress => 'Adresse kopieren';

  @override
  String get addressCopied => 'Adresse kopiert';

  @override
  String get showAddressQr => 'QR-Code anzeigen';

  @override
  String addressQrLabel(String address) {
    return 'QR-Code der Lightning-Adresse $address';
  }

  @override
  String get shareAddress => 'Adresse teilen';

  @override
  String get waitingForPayment => 'Warte auf Zahlung';

  @override
  String get expiresSoon => 'Läuft in weniger als einer Minute ab';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Läuft in $minutes Minuten ab',
      one: 'Läuft in 1 Minute ab',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Läuft in $hours Stunden ab',
      one: 'Läuft in 1 Stunde ab',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'Diese Rechnung ist abgelaufen. Erstelle eine neue, um diese Zahlung zu empfangen.';

  @override
  String get newInvoice => 'Neue Rechnung';

  @override
  String get paymentReceived => 'Zahlung empfangen';

  @override
  String receivedInto(String name) {
    return 'Auf $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Zahlung empfangen: $amount sats auf $name';
  }

  @override
  String get done => 'Fertig';

  @override
  String get close => 'Schließen';

  @override
  String get recentActivity => 'Letzte Aktivität';

  @override
  String get activityLoading => 'Aktivität wird geladen';

  @override
  String get noActivity => 'Noch keine Zahlungen.';

  @override
  String get activityUnreachable =>
      'Lumen konnte die Aktivität dieser Wallet nicht laden.';

  @override
  String get activityNoPermission =>
      'Diese Verbindung kann keine Transaktionen auflisten. Erstelle in deiner Wallet eine neue Verbindung, die das Auflisten von Transaktionen erlaubt.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Die Aktivität von $count Wallets wird nicht angezeigt: Sie konnte nicht geladen werden.',
      one: 'Die Aktivität von 1 Wallet wird nicht angezeigt: Sie konnte nicht geladen werden.',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get seeAllActivity => 'Alle Aktivitäten anzeigen';

  @override
  String get activityTitle => 'Aktivität';

  @override
  String walletActivityTitle(String name) {
    return 'Aktivität von $name';
  }

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zahlungen angezeigt',
      one: '1 Zahlung angezeigt',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => 'Ältere Zahlungen werden geladen';

  @override
  String get activityEnd =>
      'Das sind alle Zahlungen, die Lumen gespeichert hat.';

  @override
  String get transactionReceived => 'Empfangen';

  @override
  String get transactionSent => 'Gesendet';

  @override
  String amountReceived(String amount) {
    return '$amount sats empfangen';
  }

  @override
  String amountSent(String amount) {
    return '$amount sats gesendet';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet, $when';
  }

  @override
  String get justNow => 'Gerade eben';

  @override
  String minutesAgo(int minutes) {
    return 'Vor $minutes Min.';
  }

  @override
  String hoursAgo(int hours) {
    return 'Vor $hours Std.';
  }

  @override
  String get yesterday => 'Gestern';

  @override
  String get columnDescription => 'Beschreibung';

  @override
  String get columnWallet => 'Wallet';

  @override
  String get columnDate => 'Datum';

  @override
  String get columnAmount => 'Betrag';

  @override
  String get send => 'Senden';

  @override
  String get sendTo => 'An';

  @override
  String get sendToHint => 'Lightning-Rechnung oder Lightning-Adresse';

  @override
  String get paste => 'Einfügen';

  @override
  String get payFrom => 'Bezahlen mit';

  @override
  String get chooseWalletThatPays => 'Wähle die Wallet, die bezahlt';

  @override
  String get amountSetByLink => 'Betrag durch den Link festgelegt';

  @override
  String get amountSetByInvoice => 'Betrag durch die Rechnung festgelegt';

  @override
  String get reviewPayment => 'Prüfen';

  @override
  String get checkingPayment => 'Wird geprüft';

  @override
  String get youAreSending => 'Du sendest';

  @override
  String get detailTo => 'An';

  @override
  String get detailNote => 'Notiz';

  @override
  String get detailFrom => 'Von';

  @override
  String get detailNetwork => 'Netzwerk';

  @override
  String get detailFeePaid => 'Gezahlte Gebühr';

  @override
  String get detailDate => 'Datum';

  @override
  String get detailPaymentHash => 'Zahlungs-Hash';

  @override
  String get copyPaymentHash => 'Zahlungs-Hash kopieren';

  @override
  String get paymentHashCopied => 'Zahlungs-Hash kopiert';

  @override
  String get paymentTitle => 'Zahlung';

  @override
  String get paymentNotFound => 'Lumen hat diese Zahlung nicht mehr.';

  @override
  String get copyPreimage => 'Preimage kopieren';

  @override
  String get preimageCopied => 'Preimage kopiert';

  @override
  String get shareReceipt => 'Beleg teilen';

  @override
  String get receiptPreimage => 'Preimage';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get liquidAddress => 'Liquid-Adresse';

  @override
  String get lightningInvoice => 'Lightning-Rechnung';

  @override
  String sendAmount(String amount) {
    return '$amount sats senden';
  }

  @override
  String get sendingPayment => 'Wird gesendet';

  @override
  String get editPayment => 'Zahlung bearbeiten';

  @override
  String get paymentSent => 'Zahlung gesendet';

  @override
  String sentTo(String label) {
    return 'An $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Zahlung gesendet: $amount sats von $name';
  }

  @override
  String get errorToEmpty =>
      'Füge eine Lightning-Rechnung oder eine Lightning-Adresse ein.';

  @override
  String get errorToUnrecognized =>
      'Das ist weder eine Lightning-Rechnung noch eine Lightning-Adresse. Eine Rechnung beginnt mit lnbc, eine Adresse sieht aus wie name@example.com.';

  @override
  String get errorInvoiceNoAmount =>
      'Diese Rechnung lässt den Betrag offen, was Lumen noch nicht bezahlen kann. Bitte den Empfänger um eine Rechnung mit Betrag.';

  @override
  String get errorWrongNetwork =>
      'Das ist eine Liquid-Testnet-Adresse. Bitte den Empfänger um eine Adresse im Liquid-Hauptnetz.';

  @override
  String get errorUnsupportedAsset =>
      'Diese Anfrage gilt einem anderen Liquid-Asset als L-BTC, das Lumen noch nicht senden kann. Bitte den Empfänger um eine Adresse für L-BTC.';

  @override
  String get errorNoWalletPaysAddress =>
      'Keine deiner Wallets kann an eine Liquid-Adresse zahlen. Bitte den Empfänger stattdessen um eine Lightning-Rechnung oder Lightning-Adresse.';

  @override
  String get errorNoWalletPaysInvoice =>
      'Keine deiner Wallets kann eine Lightning-Rechnung oder Lightning-Adresse bezahlen. Bitte den Empfänger stattdessen um eine Liquid-Adresse.';

  @override
  String get errorInvoiceExpired =>
      'Diese Rechnung ist abgelaufen. Bitte den Empfänger um eine neue.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label akzeptiert $min bis $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen konnte $label nicht erreichen. Prüfe die Adresse und deine Verbindung, und versuche es dann erneut.';
  }

  @override
  String recipientRefused(String label) {
    return '$label kann gerade keine Zahlungen empfangen. Prüfe die Adresse mit dem Empfänger.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label hat eine Rechnung über einen anderen Betrag gesendet, deshalb hat Lumen sie nicht bezahlt.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name enthält $balance sats, nicht genug für diese Zahlung. Bezahle mit einer anderen Wallet oder verringere den Betrag.';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen konnte $name nicht erreichen, daher wurde nichts gesendet. Prüfe, ob sie online ist, und versuche es dann erneut.';
  }

  @override
  String get sendNoPermission =>
      'Diese Verbindung kann nicht bezahlen. Erstelle in deiner Wallet eine neue Verbindung, die Zahlungen erlaubt.';

  @override
  String sendInsufficientBalance(String name) {
    return '$name enthält nicht genug sats für diese Zahlung und ihre Gebühr. Bezahle mit einer anderen Wallet oder verringere den Betrag.';
  }

  @override
  String get sendBudgetExceeded =>
      'Diese Verbindung hat ihr Ausgabenbudget aufgebraucht. Erhöhe es in den NWC-Einstellungen deiner Wallet oder bezahle mit einer anderen Wallet.';

  @override
  String get sendFailed =>
      'Die Zahlung ist nicht durchgegangen, oft weil keine Route zum Empfänger gefunden wurde. Versuche es später erneut oder bezahle mit einer anderen Wallet.';

  @override
  String sendUnconfirmed(String name) {
    return '$name hat die Zahlung nicht rechtzeitig bestätigt. Sie kann noch durchgehen: Prüfe die letzte Aktivität, bevor du es erneut versuchst.';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get security => 'Sicherheit';

  @override
  String get general => 'Allgemein';

  @override
  String get language => 'Sprache';

  @override
  String get deviceLanguage => 'Gerätesprache';

  @override
  String get appLock => 'App-Sperre';

  @override
  String get appLockHint =>
      'Fragt beim Öffnen von Lumen nach deiner Passphrase und verschlüsselt damit deine Wallets';

  @override
  String get changePassphrase => 'Passphrase ändern';

  @override
  String get lockNow => 'Jetzt sperren';

  @override
  String keyboardShortcut(String keys) {
    return 'Tastenkürzel: $keys';
  }

  @override
  String get turnOnAppLock => 'App-Sperre einschalten';

  @override
  String get passphraseLead =>
      'Wähle eine Passphrase mit mindestens 12 Zeichen. Ein paar Wörter, die nichts miteinander zu tun haben, sind lang und leicht zu merken.';

  @override
  String get passphraseWarning =>
      'Wenn du sie vergisst, kommst du nur wieder hinein, indem du Lumen zurücksetzt. Dabei werden deine Wallets von diesem Gerät entfernt. Dein Guthaben bleibt bei deinen Wallet-Diensten.';

  @override
  String get passphraseLabel => 'Passphrase';

  @override
  String get newPassphraseLabel => 'Neue Passphrase';

  @override
  String get confirmPassphraseLabel => 'Noch einmal eingeben';

  @override
  String get currentPassphraseLabel => 'Aktuelle Passphrase';

  @override
  String get showPassphrase => 'Passphrase anzeigen';

  @override
  String get hidePassphrase => 'Passphrase verbergen';

  @override
  String get turnOn => 'Einschalten';

  @override
  String get errorPassphraseShort =>
      'Verwende mindestens 12 Zeichen. Ein paar Wörter hintereinander sind leicht zu merken.';

  @override
  String get errorPassphraseMismatch =>
      'Die beiden Passphrasen stimmen nicht überein. Gib zweimal dieselbe ein.';

  @override
  String get errorPassphraseWrong =>
      'Das ist nicht deine Passphrase. Prüfe sie und versuche es erneut.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Zu viele falsche Passphrasen. Versuche es in $count Sekunden erneut.',
      one: 'Zu viele falsche Passphrasen. Versuche es in 1 Sekunde erneut.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Zu viele falsche Passphrasen. Versuche es in $count Minuten erneut.',
      one: 'Zu viele falsche Passphrasen. Versuche es in 1 Minute erneut.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'Lumen konnte deine Passphrase nicht speichern. Versuche es erneut.';

  @override
  String get turnOffTitle => 'App-Sperre ausschalten?';

  @override
  String get turnOffBody =>
      'Lumen öffnet sich dann ohne Passphrase, und deine Wallets werden nicht mehr verschlüsselt.';

  @override
  String get turnOff => 'Ausschalten';

  @override
  String get lockedTitle => 'Lumen ist gesperrt';

  @override
  String get lockedLead =>
      'Gib deine Passphrase ein, um deine Wallets zu öffnen.';

  @override
  String get unlock => 'Entsperren';

  @override
  String get forgotPassphrase => 'Passphrase vergessen?';

  @override
  String get resetTitle => 'Lumen zurücksetzen?';

  @override
  String get resetBody =>
      'Lumen entfernt deine Wallets und die App-Sperre von diesem Gerät. Dein Guthaben bleibt bei deinen Wallet-Diensten: Füge jede Wallet mit ihrem Verbindungsstring erneut hinzu.';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get errorPassphraseEmpty => 'Gib deine Passphrase ein.';

  @override
  String get scan => 'Scannen';

  @override
  String get scanQrCode => 'QR-Code scannen';

  @override
  String get scanHint => 'Richte die Kamera auf einen QR-Code.';

  @override
  String get turnOnLight => 'Taschenlampe einschalten';

  @override
  String get turnOffLight => 'Taschenlampe ausschalten';

  @override
  String get cameraNeeded =>
      'Erlaube Lumen, die Kamera zum Scannen von QR-Codes zu nutzen. Du kannst diesen Bildschirm auch schließen und den Text stattdessen einfügen.';

  @override
  String get allowCamera => 'Kamera erlauben';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get noCamera =>
      'Keine Kamera verfügbar. Schließe diesen Bildschirm und füge den Text stattdessen ein.';
}
