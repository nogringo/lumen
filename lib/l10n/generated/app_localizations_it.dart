// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get tagline => 'Tutti i tuoi bitcoin, in un unico posto.';

  @override
  String get supportedWallets => 'Portafogli supportati';

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
  String get addAWallet => 'Aggiungi un portafoglio';

  @override
  String get add => 'Aggiungi';

  @override
  String get addWallet => 'Aggiungi portafoglio';

  @override
  String get back => 'Indietro';

  @override
  String get connectNwcTitle => 'Connetti con NWC';

  @override
  String get connectNwcLead =>
      'Copia la stringa di connessione dalle impostazioni NWC del tuo portafoglio.';

  @override
  String get connectionStringLabel => 'Stringa di connessione';

  @override
  String get connectionStringHint => 'Inizia con nostr+walletconnect://';

  @override
  String get nameLabel => 'Nome';

  @override
  String get connect => 'Connetti';

  @override
  String get errorUriEmpty =>
      'Incolla la stringa di connessione dalle impostazioni NWC del tuo portafoglio.';

  @override
  String get errorUriNotNwc =>
      'Questa non è una stringa di connessione NWC. Deve iniziare con nostr+walletconnect://';

  @override
  String get errorUriIncomplete =>
      'Questa stringa di connessione è incompleta. Copiala di nuovo dal tuo portafoglio, per intero.';

  @override
  String get errorUriDuplicate => 'Questo portafoglio è già in Lumen.';

  @override
  String get balanceNoPermission =>
      'Questa connessione non può leggere il saldo. Nel tuo portafoglio, crea una nuova connessione che consenta di leggere il saldo.';

  @override
  String get errorNameEmpty => 'Dai un nome a questo portafoglio.';

  @override
  String get overview => 'Panoramica';

  @override
  String get totalBalance => 'Saldo totale';

  @override
  String get wallets => 'Portafogli';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'Caricamento del saldo';

  @override
  String get balanceUnavailable => 'Non disponibile';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count portafogli non sono conteggiati: i loro saldi non sono disponibili.',
      one: '1 portafoglio non è conteggiato: il suo saldo non è disponibile.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable =>
      'Lumen non è riuscito a raggiungere questo portafoglio.';

  @override
  String get tryAgain => 'Riprova';

  @override
  String walletOptions(String name) {
    return 'Opzioni di $name';
  }

  @override
  String get rename => 'Rinomina';

  @override
  String get remove => 'Rimuovi';

  @override
  String get renameTitle => 'Rinomina portafoglio';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String removeTitle(String name) {
    return 'Rimuovere $name?';
  }

  @override
  String get removeBody =>
      'Lumen dimentica questa connessione. Il portafoglio e i suoi fondi non vengono toccati, e potrai connetterlo di nuovo in seguito.';

  @override
  String get refreshBalances => 'Aggiorna i saldi';

  @override
  String get refreshBalance => 'Aggiorna il saldo';

  @override
  String get receive => 'Ricevi';

  @override
  String get receiveInto => 'Ricevi su';

  @override
  String get chooseWallet => 'Scegli il portafoglio che riceve';

  @override
  String get amountLabel => 'Importo in sats';

  @override
  String get createInvoice => 'Crea fattura';

  @override
  String get creatingInvoice => 'Creazione della fattura';

  @override
  String get errorAmountEmpty => 'Inserisci un importo di almeno 1 sat.';

  @override
  String get receiveUnreachable =>
      'Lumen non è riuscito a ottenere una fattura da questo portafoglio. Verifica che sia online, poi riprova.';

  @override
  String get receiveNoPermission =>
      'Questa connessione non può creare fatture. Nel tuo portafoglio, crea una nuova connessione che consenta di ricevere pagamenti.';

  @override
  String invoiceQrLabel(String amount) {
    return 'Codice QR della fattura Lightning da $amount sats. Il testo della fattura è qui sotto, con un pulsante per copiarlo.';
  }

  @override
  String invoiceText(String text) {
    return 'Fattura $text';
  }

  @override
  String get editAmount => 'Modifica importo';

  @override
  String get copyInvoice => 'Copia fattura';

  @override
  String get invoiceCopied => 'Fattura copiata';

  @override
  String get shareInvoice => 'Condividi fattura';

  @override
  String get waitingForPayment => 'In attesa del pagamento';

  @override
  String get expiresSoon => 'Scade tra meno di un minuto';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Scade tra $minutes minuti',
      one: 'Scade tra 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Scade tra $hours ore',
      one: 'Scade tra 1 ora',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'Questa fattura è scaduta. Creane una nuova per ricevere questo pagamento.';

  @override
  String get newInvoice => 'Nuova fattura';

  @override
  String get paymentReceived => 'Pagamento ricevuto';

  @override
  String receivedInto(String name) {
    return 'Su $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Pagamento ricevuto: $amount sats su $name';
  }

  @override
  String get done => 'Fine';

  @override
  String get close => 'Chiudi';

  @override
  String get recentActivity => 'Attività recente';

  @override
  String get activityLoading => 'Caricamento dell\'attività';

  @override
  String get noActivity => 'Ancora nessun pagamento.';

  @override
  String get activityUnreachable =>
      'Lumen non è riuscito a caricare l\'attività di questo portafoglio.';

  @override
  String get activityNoPermission =>
      'Questa connessione non può elencare le transazioni. Nel tuo portafoglio, crea una nuova connessione che consenta di elencare le transazioni.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'L\'attività di $count portafogli non è mostrata: non è stato possibile caricarla.',
      one: 'L\'attività di 1 portafoglio non è mostrata: non è stato possibile caricarla.',
    );
    return '$_temp0';
  }

  @override
  String get transactionReceived => 'Ricevuto';

  @override
  String get transactionSent => 'Inviato';

  @override
  String amountReceived(String amount) {
    return '$amount sats ricevuti';
  }

  @override
  String amountSent(String amount) {
    return '$amount sats inviati';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet, $when';
  }

  @override
  String get justNow => 'Proprio ora';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min fa';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h fa';
  }

  @override
  String get yesterday => 'Ieri';

  @override
  String get columnDescription => 'Descrizione';

  @override
  String get columnWallet => 'Portafoglio';

  @override
  String get columnDate => 'Data';

  @override
  String get columnAmount => 'Importo';

  @override
  String get send => 'Invia';

  @override
  String get sendTo => 'A';

  @override
  String get sendToHint => 'Fattura Lightning o indirizzo Lightning';

  @override
  String get paste => 'Incolla';

  @override
  String get payFrom => 'Paga da';

  @override
  String get chooseWalletThatPays => 'Scegli il portafoglio che paga';

  @override
  String get amountSetByInvoice => 'Importo fissato dalla fattura';

  @override
  String get reviewPayment => 'Verifica';

  @override
  String get checkingPayment => 'Verifica in corso';

  @override
  String get youAreSending => 'Stai inviando';

  @override
  String get detailTo => 'A';

  @override
  String get detailNote => 'Nota';

  @override
  String get detailFrom => 'Da';

  @override
  String get detailNetwork => 'Rete';

  @override
  String get detailFeePaid => 'Commissione pagata';

  @override
  String get lightningInvoice => 'Fattura Lightning';

  @override
  String sendAmount(String amount) {
    return 'Invia $amount sats';
  }

  @override
  String get sendingPayment => 'Invio in corso';

  @override
  String get editPayment => 'Modifica pagamento';

  @override
  String get paymentSent => 'Pagamento inviato';

  @override
  String sentTo(String label) {
    return 'A $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Pagamento inviato: $amount sats da $name';
  }

  @override
  String get errorToEmpty =>
      'Incolla una fattura Lightning o un indirizzo Lightning.';

  @override
  String get errorToUnrecognized =>
      'Questa non è una fattura né un indirizzo Lightning. Una fattura inizia con lnbc, un indirizzo ha la forma nome@esempio.com.';

  @override
  String get errorInvoiceNoAmount =>
      'Questa fattura lascia l\'importo libero, e Lumen non può ancora pagarla. Chiedi al destinatario una fattura con un importo.';

  @override
  String get errorInvoiceExpired =>
      'Questa fattura è scaduta. Chiedine una nuova al destinatario.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label accetta da $min a $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen non è riuscito a raggiungere $label. Verifica l\'indirizzo e la tua connessione, poi riprova.';
  }

  @override
  String recipientRefused(String label) {
    return '$label non può ricevere pagamenti in questo momento. Verifica l\'indirizzo con il destinatario.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label ha inviato una fattura per un altro importo, quindi Lumen non l\'ha pagata.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name contiene $balance sats, non abbastanza per questo pagamento. Paga da un altro portafoglio o riduci l\'importo.';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen non è riuscito a raggiungere $name, quindi non è stato inviato nulla. Verifica che sia online, poi riprova.';
  }

  @override
  String get sendNoPermission =>
      'Questa connessione non può pagare. Nel tuo portafoglio, crea una nuova connessione che consenta i pagamenti.';

  @override
  String sendInsufficientBalance(String name) {
    return '$name non contiene abbastanza sats per questo pagamento e la sua commissione. Paga da un altro portafoglio o riduci l\'importo.';
  }

  @override
  String get sendBudgetExceeded =>
      'Questa connessione ha esaurito il suo budget di spesa. Aumentalo nelle impostazioni NWC del tuo portafoglio, o paga da un altro portafoglio.';

  @override
  String get sendFailed =>
      'Il pagamento non è andato a buon fine, spesso per mancanza di un percorso verso il destinatario. Riprova più tardi, o paga da un altro portafoglio.';

  @override
  String sendUnconfirmed(String name) {
    return '$name non ha confermato il pagamento in tempo. Potrebbe ancora andare a buon fine: controlla la sua attività recente prima di riprovare.';
  }

  @override
  String get settings => 'Impostazioni';

  @override
  String get security => 'Sicurezza';

  @override
  String get general => 'Generali';

  @override
  String get language => 'Lingua';

  @override
  String get deviceLanguage => 'Lingua del dispositivo';

  @override
  String get appLock => 'Blocco app';

  @override
  String get appLockHint =>
      'Chiede la tua passphrase all\'apertura di Lumen e la usa per cifrare i tuoi portafogli';

  @override
  String get changePassphrase => 'Cambia passphrase';

  @override
  String get lockNow => 'Blocca ora';

  @override
  String get turnOnAppLock => 'Attiva il blocco app';

  @override
  String get passphraseLead =>
      'Scegli una passphrase di almeno 12 caratteri. Alcune parole scollegate tra loro sono lunghe e facili da ricordare.';

  @override
  String get passphraseWarning =>
      'Se la dimentichi, l\'unico modo per rientrare è reimpostare Lumen, che rimuove i tuoi portafogli da questo dispositivo. I tuoi fondi restano presso i servizi dei tuoi portafogli.';

  @override
  String get passphraseLabel => 'Passphrase';

  @override
  String get newPassphraseLabel => 'Nuova passphrase';

  @override
  String get confirmPassphraseLabel => 'Digitala di nuovo';

  @override
  String get currentPassphraseLabel => 'Passphrase attuale';

  @override
  String get showPassphrase => 'Mostra passphrase';

  @override
  String get hidePassphrase => 'Nascondi passphrase';

  @override
  String get turnOn => 'Attiva';

  @override
  String get errorPassphraseShort =>
      'Usa almeno 12 caratteri. Alcune parole di seguito sono facili da ricordare.';

  @override
  String get errorPassphraseMismatch =>
      'Le due passphrase sono diverse. Digita la stessa due volte.';

  @override
  String get errorPassphraseWrong =>
      'Questa non è la tua passphrase. Controllala e riprova.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Troppe passphrase errate. Riprova tra $count secondi.',
      one: 'Troppe passphrase errate. Riprova tra 1 secondo.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Troppe passphrase errate. Riprova tra $count minuti.',
      one: 'Troppe passphrase errate. Riprova tra 1 minuto.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'Lumen non è riuscito a salvare la tua passphrase. Riprova.';

  @override
  String get turnOffTitle => 'Disattivare il blocco app?';

  @override
  String get turnOffBody =>
      'Lumen si aprirà senza passphrase, e i tuoi portafogli non saranno più cifrati.';

  @override
  String get turnOff => 'Disattiva';

  @override
  String get lockedTitle => 'Lumen è bloccato';

  @override
  String get lockedLead =>
      'Inserisci la tua passphrase per aprire i tuoi portafogli.';

  @override
  String get unlock => 'Sblocca';

  @override
  String get forgotPassphrase => 'Hai dimenticato la passphrase?';

  @override
  String get resetTitle => 'Reimpostare Lumen?';

  @override
  String get resetBody =>
      'Lumen rimuove i tuoi portafogli e il blocco app da questo dispositivo. I tuoi fondi restano presso i servizi dei tuoi portafogli: aggiungi di nuovo ogni portafoglio con la sua stringa di connessione.';

  @override
  String get reset => 'Reimposta';

  @override
  String get errorPassphraseEmpty => 'Inserisci la tua passphrase.';
}
