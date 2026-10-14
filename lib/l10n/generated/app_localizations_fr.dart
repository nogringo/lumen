// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get tagline => 'Tous vos bitcoins, au même endroit.';

  @override
  String get supportedWallets => 'Portefeuilles pris en charge';

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
  String get addAWallet => 'Ajouter un portefeuille';

  @override
  String get add => 'Ajouter';

  @override
  String get addWallet => 'Ajouter un portefeuille';

  @override
  String get back => 'Retour';

  @override
  String get connectNwcTitle => 'Connexion NWC';

  @override
  String get connectNwcLead =>
      'Copiez la chaîne de connexion depuis les réglages NWC de votre portefeuille.';

  @override
  String get connectionStringLabel => 'Chaîne de connexion';

  @override
  String get connectionStringHint => 'Commence par nostr+walletconnect://';

  @override
  String get nameLabel => 'Nom';

  @override
  String get connect => 'Connecter';

  @override
  String get errorUriEmpty =>
      'Collez la chaîne de connexion depuis les réglages NWC de votre portefeuille.';

  @override
  String get errorUriNotNwc =>
      'Ce n\'est pas une chaîne de connexion NWC. Elle doit commencer par nostr+walletconnect://';

  @override
  String get errorUriIncomplete =>
      'Cette chaîne de connexion est incomplète. Copiez-la à nouveau, en entier, depuis votre portefeuille.';

  @override
  String get errorUriDuplicate => 'Ce portefeuille est déjà dans Lumen.';

  @override
  String get grantChecking => 'Vérification de ce que permet cette connexion';

  @override
  String get grantUnreachable =>
      'Lumen n\'a pas pu joindre ce portefeuille pour vérifier ce que permet la connexion. Vous pouvez quand même le connecter.';

  @override
  String get grantCan => 'Cette connexion peut';

  @override
  String get grantCannot => 'Cette connexion ne peut pas';

  @override
  String get grantAllowed => 'Autorisé';

  @override
  String get grantDenied => 'Non autorisé';

  @override
  String get abilityReadBalance => 'Voir le solde';

  @override
  String get abilityReceive => 'Créer des factures';

  @override
  String get abilityPay => 'Payer des factures';

  @override
  String get abilityListTransactions => 'Lister les transactions';

  @override
  String budgetPerDay(String amount) {
    return 'Jusqu\'à $amount sats par jour';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'Jusqu\'à $amount sats par semaine';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'Jusqu\'à $amount sats par mois';
  }

  @override
  String budgetPerYear(String amount) {
    return 'Jusqu\'à $amount sats par an';
  }

  @override
  String budgetTotal(String amount) {
    return 'Jusqu\'à $amount sats au total';
  }

  @override
  String get balanceNoPermission =>
      'Cette connexion ne peut pas lire le solde. Dans votre portefeuille, créez une nouvelle connexion qui autorise la lecture du solde.';

  @override
  String get errorNameEmpty => 'Donnez un nom à ce portefeuille.';

  @override
  String get overview => 'Vue d\'ensemble';

  @override
  String get totalBalance => 'Solde total';

  @override
  String get wallets => 'Portefeuilles';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'Chargement du solde';

  @override
  String get balanceUnavailable => 'Indisponible';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count portefeuilles ne sont pas comptés : leurs soldes sont indisponibles.',
      one: '1 portefeuille n\'est pas compté : son solde est indisponible.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable => 'Lumen n\'a pas pu joindre ce portefeuille.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get copyConnection => 'Copier la chaîne de connexion';

  @override
  String get copyConnectionTitle => 'Copier la chaîne de connexion ?';

  @override
  String get copyConnectionBody =>
      'Quiconque la possède peut utiliser ce portefeuille comme Lumen, y compris payer si cette connexion le permet. Collez-la uniquement dans une app de confiance.';

  @override
  String get copy => 'Copier';

  @override
  String get connectionCopied => 'Chaîne de connexion copiée.';

  @override
  String walletOptions(String name) {
    return 'Options de $name';
  }

  @override
  String get rename => 'Renommer';

  @override
  String get remove => 'Retirer';

  @override
  String get renameTitle => 'Renommer le portefeuille';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String removeTitle(String name) {
    return 'Retirer $name ?';
  }

  @override
  String get removeBody =>
      'Lumen oublie cette connexion. Le portefeuille et ses fonds ne sont pas touchés, et vous pourrez le reconnecter plus tard.';

  @override
  String get refreshBalances => 'Actualiser les soldes';

  @override
  String get refreshBalance => 'Actualiser le solde';

  @override
  String get receive => 'Recevoir';

  @override
  String get receiveInto => 'Vers';

  @override
  String get chooseWallet => 'Choisir le portefeuille qui reçoit';

  @override
  String get amountLabel => 'Montant en sats';

  @override
  String get createInvoice => 'Créer la facture';

  @override
  String get creatingInvoice => 'Création de la facture';

  @override
  String get errorAmountEmpty => 'Saisissez un montant d\'au moins 1 sat.';

  @override
  String get receiveUnreachable =>
      'Lumen n\'a pas pu obtenir de facture de ce portefeuille. Vérifiez qu\'il est en ligne, puis réessayez.';

  @override
  String get receiveNoPermission =>
      'Cette connexion ne peut pas créer de factures. Dans votre portefeuille, créez une nouvelle connexion qui autorise la réception de paiements.';

  @override
  String invoiceQrLabel(String amount) {
    return 'QR code de la facture Lightning de $amount sats. Le texte de la facture est en dessous, avec un bouton pour le copier.';
  }

  @override
  String invoiceText(String text) {
    return 'Facture $text';
  }

  @override
  String get editAmount => 'Modifier le montant';

  @override
  String get copyInvoice => 'Copier la facture';

  @override
  String get invoiceCopied => 'Facture copiée';

  @override
  String get shareInvoice => 'Partager la facture';

  @override
  String get lightningAddress => 'Adresse Lightning';

  @override
  String get copyAddress => 'Copier l\'adresse';

  @override
  String get addressCopied => 'Adresse copiée';

  @override
  String get showAddressQr => 'Afficher le QR code';

  @override
  String addressQrLabel(String address) {
    return 'QR code de l\'adresse Lightning $address';
  }

  @override
  String get shareAddress => 'Partager l\'adresse';

  @override
  String get waitingForPayment => 'En attente du paiement';

  @override
  String get expiresSoon => 'Expire dans moins d\'une minute';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Expire dans $minutes minutes',
      one: 'Expire dans 1 minute',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Expire dans $hours heures',
      one: 'Expire dans 1 heure',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'Cette facture a expiré. Créez-en une nouvelle pour recevoir ce paiement.';

  @override
  String get newInvoice => 'Nouvelle facture';

  @override
  String get paymentReceived => 'Paiement reçu';

  @override
  String receivedInto(String name) {
    return 'Vers $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Paiement reçu : $amount sats vers $name';
  }

  @override
  String get done => 'Terminé';

  @override
  String get close => 'Fermer';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get activityLoading => 'Chargement de l\'activité';

  @override
  String get noActivity => 'Aucun paiement pour l\'instant.';

  @override
  String get activityUnreachable =>
      'Lumen n\'a pas pu charger l\'activité de ce portefeuille.';

  @override
  String get activityNoPermission =>
      'Cette connexion ne peut pas lister les transactions. Dans votre portefeuille, créez une nouvelle connexion qui autorise la liste des transactions.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'L\'activité de $count portefeuilles n\'est pas affichée : elle n\'a pas pu être chargée.',
      one: 'L\'activité d\'1 portefeuille n\'est pas affichée : elle n\'a pas pu être chargée.',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Tout voir';

  @override
  String get seeAllActivity => 'Voir toute l\'activité';

  @override
  String get activityTitle => 'Activité';

  @override
  String walletActivityTitle(String name) {
    return 'Activité de $name';
  }

  @override
  String get showMore => 'Afficher plus';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paiements affichés',
      one: '1 paiement affiché',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => 'Chargement des paiements plus anciens';

  @override
  String get activityEnd =>
      'Ce sont tous les paiements que Lumen a enregistrés.';

  @override
  String get transactionReceived => 'Reçu';

  @override
  String get transactionSent => 'Envoyé';

  @override
  String amountReceived(String amount) {
    return 'reçu $amount sats';
  }

  @override
  String amountSent(String amount) {
    return 'envoyé $amount sats';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet, $when';
  }

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Il y a $hours h';
  }

  @override
  String get yesterday => 'Hier';

  @override
  String get columnDescription => 'Description';

  @override
  String get columnWallet => 'Portefeuille';

  @override
  String get columnDate => 'Date';

  @override
  String get columnAmount => 'Montant';

  @override
  String get send => 'Envoyer';

  @override
  String get sendTo => 'À';

  @override
  String get sendToHint => 'Facture Lightning ou adresse Lightning';

  @override
  String get paste => 'Coller';

  @override
  String get payFrom => 'Payer depuis';

  @override
  String get chooseWalletThatPays => 'Choisir le portefeuille qui paie';

  @override
  String get amountSetByInvoice => 'Montant fixé par la facture';

  @override
  String get reviewPayment => 'Vérifier';

  @override
  String get checkingPayment => 'Vérification';

  @override
  String get youAreSending => 'Vous envoyez';

  @override
  String get detailTo => 'À';

  @override
  String get detailNote => 'Note';

  @override
  String get detailFrom => 'Depuis';

  @override
  String get detailNetwork => 'Réseau';

  @override
  String get detailFeePaid => 'Frais payés';

  @override
  String get detailDate => 'Date';

  @override
  String get detailPaymentHash => 'Hash du paiement';

  @override
  String get copyPaymentHash => 'Copier le hash du paiement';

  @override
  String get paymentHashCopied => 'Hash du paiement copié';

  @override
  String get paymentTitle => 'Paiement';

  @override
  String get paymentNotFound => 'Lumen n\'a plus ce paiement.';

  @override
  String get copyPreimage => 'Copier la préimage';

  @override
  String get preimageCopied => 'Préimage copiée';

  @override
  String get shareReceipt => 'Partager le reçu';

  @override
  String get receiptPreimage => 'Préimage';

  @override
  String receiptLine(String label, String value) {
    return '$label : $value';
  }

  @override
  String get lightningInvoice => 'Facture Lightning';

  @override
  String sendAmount(String amount) {
    return 'Envoyer $amount sats';
  }

  @override
  String get sendingPayment => 'Envoi en cours';

  @override
  String get editPayment => 'Modifier le paiement';

  @override
  String get paymentSent => 'Paiement envoyé';

  @override
  String sentTo(String label) {
    return 'À $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Paiement envoyé : $amount sats depuis $name';
  }

  @override
  String get errorToEmpty =>
      'Collez une facture Lightning ou une adresse Lightning.';

  @override
  String get errorToUnrecognized =>
      'Ce n\'est ni une facture ni une adresse Lightning. Une facture commence par lnbc, une adresse ressemble à nom@exemple.com.';

  @override
  String get errorInvoiceNoAmount =>
      'Cette facture laisse le montant libre, ce que Lumen ne sait pas encore payer. Demandez une facture avec un montant.';

  @override
  String get errorInvoiceExpired =>
      'Cette facture a expiré. Demandez-en une nouvelle au destinataire.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label accepte de $min à $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen n\'a pas pu joindre $label. Vérifiez l\'adresse et votre connexion, puis réessayez.';
  }

  @override
  String recipientRefused(String label) {
    return '$label ne peut pas recevoir de paiement pour le moment. Vérifiez l\'adresse auprès du destinataire.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label a envoyé une facture d\'un autre montant, Lumen ne l\'a donc pas payée.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name contient $balance sats, pas assez pour ce paiement. Payez depuis un autre portefeuille ou baissez le montant.';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen n\'a pas pu joindre $name, rien n\'a donc été envoyé. Vérifiez qu\'il est en ligne, puis réessayez.';
  }

  @override
  String get sendNoPermission =>
      'Cette connexion ne peut pas payer. Dans votre portefeuille, créez une nouvelle connexion qui autorise les paiements.';

  @override
  String sendInsufficientBalance(String name) {
    return '$name ne contient pas assez de sats pour ce paiement et ses frais. Payez depuis un autre portefeuille ou baissez le montant.';
  }

  @override
  String get sendBudgetExceeded =>
      'Cette connexion a épuisé son budget de dépenses. Augmentez-le dans les réglages NWC de votre portefeuille, ou payez depuis un autre portefeuille.';

  @override
  String get sendFailed =>
      'Le paiement n\'est pas passé, souvent faute de route vers le destinataire. Réessayez plus tard, ou payez depuis un autre portefeuille.';

  @override
  String sendUnconfirmed(String name) {
    return '$name n\'a pas confirmé le paiement à temps. Il peut encore aboutir : vérifiez son activité récente avant de réessayer.';
  }

  @override
  String get settings => 'Réglages';

  @override
  String get security => 'Sécurité';

  @override
  String get general => 'Général';

  @override
  String get language => 'Langue';

  @override
  String get deviceLanguage => 'Langue de l\'appareil';

  @override
  String get appLock => 'Verrouillage';

  @override
  String get appLockHint =>
      'Demande votre phrase de passe à l\'ouverture de Lumen et s\'en sert pour chiffrer vos portefeuilles';

  @override
  String get changePassphrase => 'Changer la phrase de passe';

  @override
  String get lockNow => 'Verrouiller maintenant';

  @override
  String keyboardShortcut(String keys) {
    return 'Raccourci clavier : $keys';
  }

  @override
  String get turnOnAppLock => 'Activer le verrouillage';

  @override
  String get passphraseLead =>
      'Choisissez une phrase de passe d\'au moins 12 caractères. Quelques mots sans rapport entre eux sont longs et faciles à retenir.';

  @override
  String get passphraseWarning =>
      'Si vous l\'oubliez, la seule issue est de réinitialiser Lumen, ce qui retire vos portefeuilles de cet appareil. Vos fonds restent chez vos services de portefeuille.';

  @override
  String get passphraseLabel => 'Phrase de passe';

  @override
  String get newPassphraseLabel => 'Nouvelle phrase de passe';

  @override
  String get confirmPassphraseLabel => 'Saisissez-la à nouveau';

  @override
  String get currentPassphraseLabel => 'Phrase de passe actuelle';

  @override
  String get showPassphrase => 'Afficher la phrase de passe';

  @override
  String get hidePassphrase => 'Masquer la phrase de passe';

  @override
  String get turnOn => 'Activer';

  @override
  String get errorPassphraseShort =>
      'Utilisez au moins 12 caractères. Quelques mots à la suite sont faciles à retenir.';

  @override
  String get errorPassphraseMismatch =>
      'Les deux phrases de passe diffèrent. Saisissez deux fois la même.';

  @override
  String get errorPassphraseWrong =>
      'Ce n\'est pas votre phrase de passe. Vérifiez-la et réessayez.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Trop de phrases de passe erronées. Réessayez dans $count secondes.',
      one: 'Trop de phrases de passe erronées. Réessayez dans 1 seconde.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Trop de phrases de passe erronées. Réessayez dans $count minutes.',
      one: 'Trop de phrases de passe erronées. Réessayez dans 1 minute.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'Lumen n\'a pas pu enregistrer votre phrase de passe. Réessayez.';

  @override
  String get turnOffTitle => 'Désactiver le verrouillage ?';

  @override
  String get turnOffBody =>
      'Lumen s\'ouvrira sans phrase de passe, et vos portefeuilles ne seront plus chiffrés.';

  @override
  String get turnOff => 'Désactiver';

  @override
  String get lockedTitle => 'Lumen est verrouillé';

  @override
  String get lockedLead =>
      'Saisissez votre phrase de passe pour ouvrir vos portefeuilles.';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get forgotPassphrase => 'Phrase de passe oubliée ?';

  @override
  String get resetTitle => 'Réinitialiser Lumen ?';

  @override
  String get resetBody =>
      'Lumen retire vos portefeuilles et le verrouillage de cet appareil. Vos fonds restent chez vos services de portefeuille : ajoutez à nouveau chaque portefeuille avec sa chaîne de connexion.';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get errorPassphraseEmpty => 'Saisissez votre phrase de passe.';
}
