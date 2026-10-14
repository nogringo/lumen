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
  String get connecting => 'Connexion...';

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
  String get errorUriUnreachable =>
      'Lumen n\'a pas pu joindre ce portefeuille. Vérifiez qu\'il est en ligne et que la connexion est toujours active, puis réessayez.';

  @override
  String get errorUriNoBalance =>
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
  String walletsUnreachable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count portefeuilles n\'ont pas pu être joints.',
      one: '1 portefeuille n\'a pas pu être joint.',
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
}
