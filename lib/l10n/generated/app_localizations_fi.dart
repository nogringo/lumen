// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get tagline => 'Kaikki bitcoinisi yhdessä paikassa.';

  @override
  String get supportedWallets => 'Tuetut lompakot';

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
  String get addAWallet => 'Lisää lompakko';

  @override
  String get add => 'Lisää';

  @override
  String get addWallet => 'Lisää lompakko';

  @override
  String get back => 'Takaisin';

  @override
  String get connectNwcTitle => 'Yhdistä NWC:llä';

  @override
  String get connectNwcLead =>
      'Kopioi yhteysmerkkijono lompakkosi NWC-asetuksista.';

  @override
  String get connectionStringLabel => 'Yhteysmerkkijono';

  @override
  String get connectionStringHint => 'Alkaa nostr+walletconnect://';

  @override
  String get nameLabel => 'Nimi';

  @override
  String get connect => 'Yhdistä';

  @override
  String get errorUriEmpty =>
      'Liitä yhteysmerkkijono lompakkosi NWC-asetuksista.';

  @override
  String get errorUriNotNwc =>
      'Tämä ei ole NWC-yhteysmerkkijono. Sen pitäisi alkaa nostr+walletconnect://';

  @override
  String get errorUriIncomplete =>
      'Yhteysmerkkijono on puutteellinen. Kopioi se lompakostasi uudelleen kokonaisena.';

  @override
  String get errorUriDuplicate => 'Tämä lompakko on jo Lumenissa.';

  @override
  String get grantChecking => 'Tarkistetaan, mitä tämä yhteys sallii';

  @override
  String get grantUnreachable =>
      'Lumen ei saanut yhteyttä tähän lompakkoon tarkistaakseen, mitä yhteys sallii. Voit silti yhdistää sen.';

  @override
  String get grantCan => 'Tämä yhteys voi';

  @override
  String get grantCannot => 'Tämä yhteys ei voi';

  @override
  String get grantAllowed => 'Sallittu';

  @override
  String get grantDenied => 'Ei sallittu';

  @override
  String get abilityReadBalance => 'Nähdä saldon';

  @override
  String get abilityReceive => 'Luoda laskuja';

  @override
  String get abilityPay => 'Maksaa laskuja';

  @override
  String get abilityListTransactions => 'Listata tapahtumat';

  @override
  String budgetPerDay(String amount) {
    return 'Enintään $amount satsia päivässä';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'Enintään $amount satsia viikossa';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'Enintään $amount satsia kuukaudessa';
  }

  @override
  String budgetPerYear(String amount) {
    return 'Enintään $amount satsia vuodessa';
  }

  @override
  String budgetTotal(String amount) {
    return 'Enintään $amount satsia yhteensä';
  }

  @override
  String get balanceNoPermission =>
      'Tämä yhteys ei voi lukea saldoa. Luo lompakossasi uusi yhteys, joka sallii saldon lukemisen.';

  @override
  String get errorNameEmpty => 'Anna lompakolle nimi.';

  @override
  String get overview => 'Yleiskatsaus';

  @override
  String get totalBalance => 'Kokonaissaldo';

  @override
  String get wallets => 'Lompakot';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'Ladataan saldoa';

  @override
  String get balanceUnavailable => 'Ei saatavilla';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count lompakkoa ei ole mukana summassa: niiden saldot eivät ole saatavilla.',
      one: '1 lompakko ei ole mukana summassa: sen saldo ei ole saatavilla.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable => 'Lumen ei tavoittanut tätä lompakkoa.';

  @override
  String get tryAgain => 'Yritä uudelleen';

  @override
  String walletOptions(String name) {
    return '$name: valinnat';
  }

  @override
  String get rename => 'Nimeä uudelleen';

  @override
  String get remove => 'Poista';

  @override
  String get renameTitle => 'Nimeä lompakko uudelleen';

  @override
  String get save => 'Tallenna';

  @override
  String get cancel => 'Peruuta';

  @override
  String removeTitle(String name) {
    return 'Poistetaanko $name?';
  }

  @override
  String get removeBody =>
      'Lumen unohtaa tämän yhteyden. Muutos ei vaikuta lompakkoon eikä sen varoihin, ja voit yhdistää sen myöhemmin uudelleen.';

  @override
  String get refreshBalances => 'Päivitä saldot';

  @override
  String get refreshBalance => 'Päivitä saldo';

  @override
  String get receive => 'Vastaanota';

  @override
  String get receiveInto => 'Vastaanottava lompakko';

  @override
  String get chooseWallet => 'Valitse vastaanottava lompakko';

  @override
  String get amountLabel => 'Summa (sats)';

  @override
  String get createInvoice => 'Luo lasku';

  @override
  String get creatingInvoice => 'Luodaan laskua';

  @override
  String get errorAmountEmpty => 'Anna summa, joka on vähintään 1 sat.';

  @override
  String get receiveUnreachable =>
      'Lumen ei saanut laskua tältä lompakolta. Tarkista, että se on verkossa, ja yritä uudelleen.';

  @override
  String get receiveNoPermission =>
      'Tämä yhteys ei voi luoda laskuja. Luo lompakossasi uusi yhteys, joka sallii maksujen vastaanottamisen.';

  @override
  String invoiceQrLabel(String amount) {
    return 'Lightning-laskun QR-koodi, $amount sats. Laskun teksti on alla, ja siinä on kopiointipainike.';
  }

  @override
  String invoiceText(String text) {
    return 'Lasku $text';
  }

  @override
  String get editAmount => 'Muokkaa summaa';

  @override
  String get copyInvoice => 'Kopioi lasku';

  @override
  String get invoiceCopied => 'Lasku kopioitu';

  @override
  String get shareInvoice => 'Jaa lasku';

  @override
  String get waitingForPayment => 'Odotetaan maksua';

  @override
  String get expiresSoon => 'Vanhenee alle minuutin kuluttua';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Vanhenee $minutes minuutin kuluttua',
      one: 'Vanhenee 1 minuutin kuluttua',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Vanhenee $hours tunnin kuluttua',
      one: 'Vanhenee 1 tunnin kuluttua',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'Tämä lasku vanheni. Luo uusi lasku vastaanottaaksesi tämän maksun.';

  @override
  String get newInvoice => 'Uusi lasku';

  @override
  String get paymentReceived => 'Maksu vastaanotettu';

  @override
  String receivedInto(String name) {
    return 'Lompakkoon $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Maksu vastaanotettu: $amount sats lompakkoon $name';
  }

  @override
  String get done => 'Valmis';

  @override
  String get close => 'Sulje';

  @override
  String get recentActivity => 'Viimeaikainen toiminta';

  @override
  String get activityLoading => 'Ladataan toimintaa';

  @override
  String get noActivity => 'Ei vielä maksuja.';

  @override
  String get activityUnreachable =>
      'Lumen ei voinut ladata tämän lompakon toimintaa.';

  @override
  String get activityNoPermission =>
      'Tämä yhteys ei voi listata tapahtumia. Luo lompakossasi uusi yhteys, joka sallii tapahtumien listaamisen.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toimintaa ei näytetä $count lompakosta: sitä ei voitu ladata.',
      one: 'Toimintaa ei näytetä 1 lompakosta: sitä ei voitu ladata.',
    );
    return '$_temp0';
  }

  @override
  String get transactionReceived => 'Vastaanotettu';

  @override
  String get transactionSent => 'Lähetetty';

  @override
  String amountReceived(String amount) {
    return 'vastaanotettu $amount sats';
  }

  @override
  String amountSent(String amount) {
    return 'lähetetty $amount sats';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet, $when';
  }

  @override
  String get justNow => 'Juuri nyt';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min sitten';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h sitten';
  }

  @override
  String get yesterday => 'Eilen';

  @override
  String get columnDescription => 'Kuvaus';

  @override
  String get columnWallet => 'Lompakko';

  @override
  String get columnDate => 'Päivämäärä';

  @override
  String get columnAmount => 'Summa';

  @override
  String get send => 'Lähetä';

  @override
  String get sendTo => 'Vastaanottaja';

  @override
  String get sendToHint => 'Lightning-lasku tai Lightning-osoite';

  @override
  String get paste => 'Liitä';

  @override
  String get payFrom => 'Maksava lompakko';

  @override
  String get chooseWalletThatPays => 'Valitse maksava lompakko';

  @override
  String get amountSetByInvoice => 'Laskun määräämä summa';

  @override
  String get reviewPayment => 'Tarkista';

  @override
  String get checkingPayment => 'Tarkistetaan';

  @override
  String get youAreSending => 'Olet lähettämässä';

  @override
  String get detailTo => 'Vastaanottaja';

  @override
  String get detailNote => 'Viesti';

  @override
  String get detailFrom => 'Maksaja';

  @override
  String get detailNetwork => 'Verkko';

  @override
  String get detailFeePaid => 'Maksettu kulu';

  @override
  String get lightningInvoice => 'Lightning-lasku';

  @override
  String sendAmount(String amount) {
    return 'Lähetä $amount sats';
  }

  @override
  String get sendingPayment => 'Lähetetään';

  @override
  String get editPayment => 'Muokkaa maksua';

  @override
  String get paymentSent => 'Maksu lähetetty';

  @override
  String sentTo(String label) {
    return 'Vastaanottaja: $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Maksu lähetetty: $amount sats lompakosta $name';
  }

  @override
  String get errorToEmpty => 'Liitä Lightning-lasku tai Lightning-osoite.';

  @override
  String get errorToUnrecognized =>
      'Tämä ei ole Lightning-lasku eikä Lightning-osoite. Lasku alkaa lnbc, osoite näyttää tältä: nimi@example.com.';

  @override
  String get errorInvoiceNoAmount =>
      'Tässä laskussa ei ole summaa, eikä Lumen osaa vielä maksaa sellaista. Pyydä vastaanottajalta lasku, jossa on summa.';

  @override
  String get errorInvoiceExpired =>
      'Tämä lasku vanheni. Pyydä vastaanottajalta uusi.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label hyväksyy vähintään $min ja enintään $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen ei tavoittanut osoitetta $label. Tarkista osoite ja verkkoyhteytesi ja yritä uudelleen.';
  }

  @override
  String recipientRefused(String label) {
    return '$label ei voi vastaanottaa maksuja juuri nyt. Tarkista osoite vastaanottajalta.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label lähetti laskun eri summalle, joten Lumen ei maksanut sitä.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return 'Lompakossa $name on $balance sats, mikä ei riitä tähän maksuun. Maksa toisesta lompakosta tai pienennä summaa.';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen ei tavoittanut lompakkoa $name, joten mitään ei lähetetty. Tarkista, että se on verkossa, ja yritä uudelleen.';
  }

  @override
  String get sendNoPermission =>
      'Tämä yhteys ei voi maksaa. Luo lompakossasi uusi yhteys, joka sallii maksut.';

  @override
  String sendInsufficientBalance(String name) {
    return 'Lompakossa $name ei ole tarpeeksi varoja tähän maksuun ja sen kuluun. Maksa toisesta lompakosta tai pienennä summaa.';
  }

  @override
  String get sendBudgetExceeded =>
      'Tämä yhteys on käyttänyt kulutusbudjettinsa loppuun. Korota sitä lompakkosi NWC-asetuksista tai maksa toisesta lompakosta.';

  @override
  String get sendFailed =>
      'Maksu ei mennyt läpi, usein koska reittiä vastaanottajalle ei löytynyt. Yritä myöhemmin uudelleen tai maksa toisesta lompakosta.';

  @override
  String sendUnconfirmed(String name) {
    return 'Lompakko $name ei vahvistanut maksua ajoissa. Maksu voi vielä mennä läpi: tarkista lompakon viimeaikainen toiminta ennen kuin yrität uudelleen.';
  }

  @override
  String get settings => 'Asetukset';

  @override
  String get security => 'Turvallisuus';

  @override
  String get general => 'Yleiset';

  @override
  String get language => 'Kieli';

  @override
  String get deviceLanguage => 'Laitteen kieli';

  @override
  String get appLock => 'Sovelluslukitus';

  @override
  String get appLockHint =>
      'Kysyy tunnuslausetta, kun Lumen avataan, ja salaa lompakkosi sillä';

  @override
  String get changePassphrase => 'Vaihda tunnuslause';

  @override
  String get lockNow => 'Lukitse nyt';

  @override
  String keyboardShortcut(String keys) {
    return 'Pikanäppäin: $keys';
  }

  @override
  String get turnOnAppLock => 'Ota sovelluslukitus käyttöön';

  @override
  String get passphraseLead =>
      'Valitse vähintään 12 merkin tunnuslause. Muutama toisiinsa liittymätön sana on pitkä ja helppo muistaa.';

  @override
  String get passphraseWarning =>
      'Jos unohdat sen, ainoa tapa päästä takaisin on nollata Lumen, mikä poistaa lompakkosi tältä laitteelta. Varasi pysyvät lompakkopalveluissasi.';

  @override
  String get passphraseLabel => 'Tunnuslause';

  @override
  String get newPassphraseLabel => 'Uusi tunnuslause';

  @override
  String get confirmPassphraseLabel => 'Kirjoita se uudelleen';

  @override
  String get currentPassphraseLabel => 'Nykyinen tunnuslause';

  @override
  String get showPassphrase => 'Näytä tunnuslause';

  @override
  String get hidePassphrase => 'Piilota tunnuslause';

  @override
  String get turnOn => 'Ota käyttöön';

  @override
  String get errorPassphraseShort =>
      'Käytä vähintään 12 merkkiä. Muutama sana peräkkäin on helppo muistaa.';

  @override
  String get errorPassphraseMismatch =>
      'Tunnuslauseet eroavat. Kirjoita sama tunnuslause kahdesti.';

  @override
  String get errorPassphraseWrong =>
      'Tämä ei ole tunnuslauseesi. Tarkista se ja yritä uudelleen.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Liian monta väärää tunnuslausetta. Yritä uudelleen $count sekunnin kuluttua.',
      one: 'Liian monta väärää tunnuslausetta. Yritä uudelleen 1 sekunnin kuluttua.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Liian monta väärää tunnuslausetta. Yritä uudelleen $count minuutin kuluttua.',
      one: 'Liian monta väärää tunnuslausetta. Yritä uudelleen 1 minuutin kuluttua.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'Lumen ei voinut tallentaa tunnuslausettasi. Yritä uudelleen.';

  @override
  String get turnOffTitle => 'Poistetaanko sovelluslukitus käytöstä?';

  @override
  String get turnOffBody =>
      'Lumen avautuu ilman tunnuslausetta, eikä lompakoitasi enää salata.';

  @override
  String get turnOff => 'Poista käytöstä';

  @override
  String get lockedTitle => 'Lumen on lukittu';

  @override
  String get lockedLead => 'Avaa lompakkosi antamalla tunnuslauseesi.';

  @override
  String get unlock => 'Avaa lukitus';

  @override
  String get forgotPassphrase => 'Unohditko tunnuslauseesi?';

  @override
  String get resetTitle => 'Nollataanko Lumen?';

  @override
  String get resetBody =>
      'Lumen poistaa lompakkosi ja sovelluslukituksen tältä laitteelta. Varasi pysyvät lompakkopalveluissasi: lisää kukin lompakko uudelleen sen yhteysmerkkijonolla.';

  @override
  String get reset => 'Nollaa';

  @override
  String get errorPassphraseEmpty => 'Anna tunnuslauseesi.';
}
