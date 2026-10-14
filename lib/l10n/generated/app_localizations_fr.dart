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
}
