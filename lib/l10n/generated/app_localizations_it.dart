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
  String get grantChecking => 'Verifica di cosa consente questa connessione';

  @override
  String get grantUnreachable =>
      'Lumen non è riuscito a raggiungere questo portafoglio per verificare cosa consente la connessione. Puoi comunque collegarlo.';

  @override
  String get grantCan => 'Questa connessione può';

  @override
  String get grantCannot => 'Questa connessione non può';

  @override
  String get grantAllowed => 'Consentito';

  @override
  String get grantDenied => 'Non consentito';

  @override
  String get abilityReadBalance => 'Vedere il saldo';

  @override
  String get abilityReceive => 'Creare fatture';

  @override
  String get abilityPay => 'Pagare fatture';

  @override
  String get abilityListTransactions => 'Elencare le transazioni';

  @override
  String budgetPerDay(String amount) {
    return 'Fino a $amount sats al giorno';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'Fino a $amount sats a settimana';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'Fino a $amount sats al mese';
  }

  @override
  String budgetPerYear(String amount) {
    return 'Fino a $amount sats all\'anno';
  }

  @override
  String budgetTotal(String amount) {
    return 'Fino a $amount sats in totale';
  }

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
  String get copyConnection => 'Copia stringa di connessione';

  @override
  String get copyConnectionTitle => 'Copiare la stringa di connessione?';

  @override
  String get copyConnectionBody =>
      'Chiunque la abbia può usare questo portafoglio come Lumen, anche per pagare se la connessione lo consente. Incollala solo in un\'app di cui ti fidi.';

  @override
  String get copy => 'Copia';

  @override
  String get connectionCopied => 'Stringa di connessione copiata.';

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
  String get lightningAddress => 'Indirizzo Lightning';

  @override
  String get copyAddress => 'Copia indirizzo';

  @override
  String get addressCopied => 'Indirizzo copiato';

  @override
  String get showAddressQr => 'Mostra codice QR';

  @override
  String addressQrLabel(String address) {
    return 'Codice QR dell\'indirizzo Lightning $address';
  }

  @override
  String get shareAddress => 'Condividi indirizzo';

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
  String get seeAll => 'Vedi tutto';

  @override
  String get seeAllActivity => 'Vedi tutta l\'attività';

  @override
  String get activityTitle => 'Attività';

  @override
  String walletActivityTitle(String name) {
    return 'Attività di $name';
  }

  @override
  String get showMore => 'Mostra altro';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagamenti mostrati',
      one: '1 pagamento mostrato',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => 'Caricamento dei pagamenti precedenti';

  @override
  String get activityEnd => 'Questi sono tutti i pagamenti salvati da Lumen.';

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
  String get amountSetByLink => 'Importo fissato dal link';

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
  String get detailDate => 'Data';

  @override
  String get detailPaymentHash => 'Hash del pagamento';

  @override
  String get copyPaymentHash => 'Copia hash del pagamento';

  @override
  String get paymentHashCopied => 'Hash del pagamento copiato';

  @override
  String get paymentTitle => 'Pagamento';

  @override
  String get paymentNotFound => 'Lumen non ha più questo pagamento.';

  @override
  String get copyPreimage => 'Copia preimmagine';

  @override
  String get preimageCopied => 'Preimmagine copiata';

  @override
  String get shareReceipt => 'Condividi ricevuta';

  @override
  String get receiptPreimage => 'Preimmagine';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get liquidAddress => 'Indirizzo Liquid';

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
  String get errorWrongNetwork =>
      'Questo è un indirizzo della testnet Liquid. Chiedi al destinatario un indirizzo della rete Liquid principale.';

  @override
  String get errorUnsupportedAsset =>
      'Questa richiesta riguarda un asset Liquid diverso da L-BTC, che Lumen non può ancora inviare. Chiedi al destinatario un indirizzo per L-BTC.';

  @override
  String get errorNoWalletPaysAddress =>
      'Nessuno dei tuoi portafogli può pagare un indirizzo Liquid. Chiedi invece al destinatario una fattura o un indirizzo Lightning.';

  @override
  String get errorNoWalletPaysInvoice =>
      'Nessuno dei tuoi portafogli può pagare una fattura o un indirizzo Lightning. Chiedi invece al destinatario un indirizzo Liquid.';

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
  String keyboardShortcut(String keys) {
    return 'Scorciatoia da tastiera: $keys';
  }

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

  @override
  String get scan => 'Scansiona';

  @override
  String get scanQrCode => 'Scansiona un codice QR';

  @override
  String get scanHint => 'Inquadra un codice QR con la fotocamera.';

  @override
  String get turnOnLight => 'Accendi la torcia';

  @override
  String get turnOffLight => 'Spegni la torcia';

  @override
  String get cameraNeeded =>
      'Consenti a Lumen di usare la fotocamera per scansionare i codici QR. Puoi anche chiudere questa schermata e incollare il testo.';

  @override
  String get allowCamera => 'Consenti fotocamera';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get noCamera =>
      'Nessuna fotocamera disponibile. Chiudi questa schermata e incolla il testo.';

  @override
  String get addWalletLead =>
      'Crea un nuovo portafoglio o ripristinane uno che hai già.';

  @override
  String get addLightningTitle => 'Portafoglio Lightning';

  @override
  String get addLightningBody =>
      'Connetti un nodo o un servizio di portafoglio con Nostr Wallet Connect (NIP-47).';

  @override
  String get addLiquidBody =>
      'Trasferimenti veloci e riservati sulla sidechain Liquid. Lumen custodisce le chiavi.';

  @override
  String get liquidStartTitle => 'Portafoglio Liquid';

  @override
  String get liquidStartLead =>
      'Lumen crea il portafoglio e ne conserva le chiavi su questo dispositivo. Una frase di recupero di 12 parole ti permette di riaverlo.';

  @override
  String get liquidPointFast => 'I pagamenti si confermano in circa un minuto';

  @override
  String get liquidPointConfidential =>
      'Gli importi restano nascosti a chi osserva la catena';

  @override
  String get liquidPointKeys => 'Le tue chiavi restano sul tuo dispositivo';

  @override
  String get createLiquidWallet => 'Crea un nuovo portafoglio';

  @override
  String get newLiquidTitle => 'Nuovo portafoglio Liquid';

  @override
  String get phraseIntroHeading => 'Prima di tutto, la frase di recupero';

  @override
  String get phraseIntroBody =>
      'Lumen ti mostrerà 12 parole. Sono l\'unico modo per riavere questo portafoglio se perdi o ripristini questo dispositivo, e chiunque le abbia può spenderne i fondi.';

  @override
  String get phrasePointPaper => 'Scrivile su carta, in ordine';

  @override
  String get phrasePointOffline =>
      'Tienile offline: niente screenshot, foto o note nel cloud';

  @override
  String get phrasePointNeverAsked =>
      'Lumen le chiede solo per ripristinare un portafoglio';

  @override
  String get showPhrase => 'Mostra le 12 parole';

  @override
  String get liquidUnavailable =>
      'Lumen non è riuscito ad avviare Liquid su questo dispositivo. Riprova più tardi.';

  @override
  String get phraseTitle => 'Frase di recupero';

  @override
  String get phraseLead =>
      'Scrivi queste 12 parole su carta, in questo ordine. Poi ne digiterai tre.';

  @override
  String phraseWord(int number, int total, String word) {
    return 'Parola $number di $total, $word';
  }

  @override
  String get phraseWrittenDown => 'Le ho scritte';

  @override
  String get checkPhraseTitle => 'Verifica la frase';

  @override
  String get checkPhraseLead =>
      'Digita queste parole dal tuo foglio, per essere sicuro che siano giuste.';

  @override
  String wordLabel(int number, int total) {
    return 'Parola $number di $total';
  }

  @override
  String errorWordEmpty(int number) {
    return 'Digita la parola $number dal tuo foglio.';
  }

  @override
  String errorWordMismatch(int number) {
    return 'Questa non è la parola $number. Controlla il foglio e digitala di nuovo.';
  }

  @override
  String wordSuggestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggerimenti',
      one: '1 suggerimento',
    );
    return '$_temp0';
  }

  @override
  String get showWordsAgain => 'Rivedi le parole';

  @override
  String get testnet => 'Testnet';

  @override
  String get testnetHint =>
      'Solo per i test. Le monete testnet non hanno valore.';

  @override
  String get createWallet => 'Crea portafoglio';

  @override
  String get errorSaveWallet =>
      'Lumen non è riuscito a salvare il portafoglio. Riprova.';

  @override
  String get restoreLiquidWallet => 'Ripristina un portafoglio';

  @override
  String get restoreLiquidTitle => 'Ripristina un portafoglio Liquid';

  @override
  String get restoreLead =>
      'Digita le parole della tua frase di recupero, in ordine. Puoi anche incollare l\'intera frase nel primo campo.';

  @override
  String get errorWordUnknown =>
      'Questa parola non è nell\'elenco delle frasi di recupero. Controlla come è scritta.';

  @override
  String get errorPhraseChecksum =>
      'Queste parole non formano una frase di recupero. Una potrebbe essere sbagliata o fuori posto: confrontale una per una con il tuo foglio.';

  @override
  String get restoreScanning =>
      'Ricerca dei pagamenti di questo portafoglio. Può richiedere un minuto.';

  @override
  String get restoreWallet => 'Ripristina portafoglio';

  @override
  String get errorRestoreUnreachable =>
      'Lumen non è riuscito a raggiungere il server Liquid per cercare i pagamenti di questo portafoglio. Controlla la connessione e riprova.';

  @override
  String get errorRestoreDuplicate => 'Questo portafoglio è già in Lumen.';

  @override
  String wordsPasted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parole inserite',
      one: '1 parola inserita',
    );
    return '$_temp0';
  }

  @override
  String get phraseLength => 'Lunghezza della frase';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parole',
      one: '1 parola',
    );
    return '$_temp0';
  }

  @override
  String get gettingAddress => 'Recupero di un indirizzo';

  @override
  String get addressUnavailable =>
      'Lumen non è riuscito a ottenere un indirizzo da questo portafoglio. Verifica la connessione, poi riprova.';

  @override
  String get liquidQrLabel =>
      'Codice QR dell\'indirizzo Liquid. L\'indirizzo è qui sotto, con un pulsante per copiarlo.';

  @override
  String liquidAmountQrLabel(String amount) {
    return 'Codice QR dell\'indirizzo Liquid per $amount sats. L\'indirizzo è qui sotto, con un pulsante per copiarlo.';
  }

  @override
  String addressText(String groups) {
    return 'Indirizzo $groups';
  }

  @override
  String get addAmount => 'Aggiungi importo';

  @override
  String get amountOptional =>
      'Facoltativo. Lascialo vuoto per ricevere qualsiasi importo.';

  @override
  String get showQrCode => 'Mostra codice QR';

  @override
  String get waitingForConfirmation => 'In attesa di conferma';

  @override
  String get confirmsSoon => 'Di solito entro 2 minuti';

  @override
  String get paymentConfirmed => 'Confermato';

  @override
  String get paymentConfirmedAnnouncement => 'Pagamento confermato';
}
