// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get tagline => 'Todas tus formas de tener bitcoin, en un solo lugar.';

  @override
  String get supportedWallets => 'Billeteras compatibles';

  @override
  String get kindLightning => 'Lightning';

  @override
  String get kindEcash => 'Ecash';

  @override
  String get kindOnchain => 'On-chain';

  @override
  String get kindLiquid => 'Liquid';

  @override
  String get lightningViaNwc => 'Lightning vía NWC';

  @override
  String get addAWallet => 'Añadir una billetera';

  @override
  String get add => 'Añadir';

  @override
  String get addWallet => 'Añadir billetera';

  @override
  String get back => 'Atrás';

  @override
  String get connectNwcTitle => 'Conectar con NWC';

  @override
  String get connectNwcLead =>
      'Copia la cadena de conexión desde los ajustes NWC de tu billetera.';

  @override
  String get connectionStringLabel => 'Cadena de conexión';

  @override
  String get connectionStringHint => 'Empieza por nostr+walletconnect://';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get connect => 'Conectar';

  @override
  String get errorUriEmpty =>
      'Pega la cadena de conexión desde los ajustes NWC de tu billetera.';

  @override
  String get errorUriNotNwc =>
      'Esto no es una cadena de conexión NWC. Debe empezar por nostr+walletconnect://';

  @override
  String get errorUriIncomplete =>
      'Esta cadena de conexión está incompleta. Vuelve a copiarla entera desde tu billetera.';

  @override
  String get errorUriDuplicate => 'Esta billetera ya está en Lumen.';

  @override
  String get grantChecking => 'Comprobando qué permite esta conexión';

  @override
  String get grantUnreachable =>
      'Lumen no pudo contactar con esta billetera para comprobar qué permite la conexión. Aun así puedes conectarla.';

  @override
  String get grantCan => 'Esta conexión puede';

  @override
  String get grantCannot => 'Esta conexión no puede';

  @override
  String get grantAllowed => 'Permitido';

  @override
  String get grantDenied => 'No permitido';

  @override
  String get abilityReadBalance => 'Ver el saldo';

  @override
  String get abilityReceive => 'Crear facturas';

  @override
  String get abilityPay => 'Pagar facturas';

  @override
  String get abilityListTransactions => 'Listar transacciones';

  @override
  String budgetPerDay(String amount) {
    return 'Hasta $amount sats al día';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'Hasta $amount sats a la semana';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'Hasta $amount sats al mes';
  }

  @override
  String budgetPerYear(String amount) {
    return 'Hasta $amount sats al año';
  }

  @override
  String budgetTotal(String amount) {
    return 'Hasta $amount sats en total';
  }

  @override
  String get balanceNoPermission =>
      'Esta conexión no puede leer el saldo. En tu billetera, crea una nueva conexión que permita leer el saldo.';

  @override
  String get errorNameEmpty => 'Ponle un nombre a esta billetera.';

  @override
  String get overview => 'Resumen';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get wallets => 'Billeteras';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'Cargando saldo';

  @override
  String get balanceUnavailable => 'No disponible';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count billeteras no se cuentan: sus saldos no están disponibles.',
      one: '1 billetera no se cuenta: su saldo no está disponible.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable => 'Lumen no pudo conectar con esta billetera.';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get copyConnection => 'Copiar cadena de conexión';

  @override
  String get copyConnectionTitle => '¿Copiar la cadena de conexión?';

  @override
  String get copyConnectionBody =>
      'Quien la tenga puede usar esta billetera como Lumen, incluso pagar si esta conexión lo permite. Pégala solo en una app de confianza.';

  @override
  String get copy => 'Copiar';

  @override
  String get connectionCopied => 'Cadena de conexión copiada.';

  @override
  String walletOptions(String name) {
    return 'Opciones de $name';
  }

  @override
  String get rename => 'Cambiar nombre';

  @override
  String get remove => 'Quitar';

  @override
  String get renameTitle => 'Cambiar nombre de la billetera';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String removeTitle(String name) {
    return '¿Quitar $name?';
  }

  @override
  String get removeBody =>
      'Lumen olvida esta conexión. La billetera y sus fondos no se ven afectados, y puedes volver a conectarla más tarde.';

  @override
  String get refreshBalances => 'Actualizar saldos';

  @override
  String get refreshBalance => 'Actualizar saldo';

  @override
  String get receive => 'Recibir';

  @override
  String get receiveInto => 'En';

  @override
  String get chooseWallet => 'Elige la billetera que recibe';

  @override
  String get amountLabel => 'Importe en sats';

  @override
  String get sendEverything => 'Enviar todo';

  @override
  String sendEverythingHint(String name) {
    return 'Todo el saldo de $name, menos la comisión.';
  }

  @override
  String get createInvoice => 'Crear factura';

  @override
  String get creatingInvoice => 'Creando factura';

  @override
  String get errorAmountEmpty => 'Introduce un importe de al menos 1 sat.';

  @override
  String get receiveUnreachable =>
      'Lumen no pudo obtener una factura de esta billetera. Comprueba que esté en línea y vuelve a intentarlo.';

  @override
  String get receiveNoPermission =>
      'Esta conexión no puede crear facturas. En tu billetera, crea una nueva conexión que permita recibir pagos.';

  @override
  String invoiceQrLabel(String amount) {
    return 'Código QR de la factura Lightning de $amount sats. El texto de la factura está debajo, con un botón para copiarlo.';
  }

  @override
  String invoiceText(String text) {
    return 'Factura $text';
  }

  @override
  String get editAmount => 'Editar importe';

  @override
  String get copyInvoice => 'Copiar factura';

  @override
  String get invoiceCopied => 'Factura copiada';

  @override
  String get shareInvoice => 'Compartir factura';

  @override
  String get lightningAddress => 'Dirección Lightning';

  @override
  String get copyAddress => 'Copiar dirección';

  @override
  String get addressCopied => 'Dirección copiada';

  @override
  String get showAddressQr => 'Mostrar código QR';

  @override
  String addressQrLabel(String address) {
    return 'Código QR de la dirección Lightning $address';
  }

  @override
  String get shareAddress => 'Compartir dirección';

  @override
  String get waitingForPayment => 'Esperando el pago';

  @override
  String get expiresSoon => 'Caduca en menos de un minuto';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Caduca en $minutes minutos',
      one: 'Caduca en 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Caduca en $hours horas',
      one: 'Caduca en 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'Esta factura caducó. Crea una nueva para recibir este pago.';

  @override
  String get newInvoice => 'Nueva factura';

  @override
  String get paymentReceived => 'Pago recibido';

  @override
  String receivedInto(String name) {
    return 'En $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Pago recibido: $amount sats en $name';
  }

  @override
  String get done => 'Listo';

  @override
  String get close => 'Cerrar';

  @override
  String get recentActivity => 'Actividad reciente';

  @override
  String get activityLoading => 'Cargando actividad';

  @override
  String get noActivity => 'Aún no hay pagos.';

  @override
  String get activityUnreachable =>
      'Lumen no pudo cargar la actividad de esta billetera.';

  @override
  String get activityNoPermission =>
      'Esta conexión no puede listar las transacciones. En tu billetera, crea una nueva conexión que permita listar las transacciones.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'No se muestra la actividad de $count billeteras: no se pudo cargar.',
      one: 'No se muestra la actividad de 1 billetera: no se pudo cargar.',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Ver todo';

  @override
  String get seeAllActivity => 'Ver toda la actividad';

  @override
  String get activityTitle => 'Actividad';

  @override
  String walletActivityTitle(String name) {
    return 'Actividad de $name';
  }

  @override
  String get showMore => 'Mostrar más';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagos mostrados',
      one: '1 pago mostrado',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => 'Cargando pagos anteriores';

  @override
  String get activityEnd => 'Estos son todos los pagos que Lumen ha guardado.';

  @override
  String get transactionReceived => 'Recibido';

  @override
  String get transactionSent => 'Enviado';

  @override
  String amountReceived(String amount) {
    return '$amount sats recibidos';
  }

  @override
  String amountSent(String amount) {
    return '$amount sats enviados';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet, $when';
  }

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Hace $hours h';
  }

  @override
  String get yesterday => 'Ayer';

  @override
  String get columnDescription => 'Descripción';

  @override
  String get columnWallet => 'Billetera';

  @override
  String get columnDate => 'Fecha';

  @override
  String get columnAmount => 'Importe';

  @override
  String get send => 'Enviar';

  @override
  String get sendTo => 'Para';

  @override
  String get sendToHint => 'Factura Lightning o dirección Lightning';

  @override
  String get sendToHintLiquid => 'Dirección Liquid';

  @override
  String get sendToHintAll =>
      'Factura Lightning, dirección Lightning o dirección Liquid';

  @override
  String get paste => 'Pegar';

  @override
  String get payFrom => 'Pagar desde';

  @override
  String get chooseWalletThatPays => 'Elige la billetera que paga';

  @override
  String get amountSetByLink => 'Importe fijado por el enlace';

  @override
  String get amountSetByInvoice => 'Importe fijado por la factura';

  @override
  String get reviewPayment => 'Revisar';

  @override
  String get checkingPayment => 'Comprobando';

  @override
  String get youAreSending => 'Vas a enviar';

  @override
  String get detailTo => 'Para';

  @override
  String get detailNote => 'Nota';

  @override
  String get detailFrom => 'Desde';

  @override
  String get detailNetwork => 'Red';

  @override
  String get detailFee => 'Comisión';

  @override
  String get detailFeePaid => 'Comisión pagada';

  @override
  String get detailDate => 'Fecha';

  @override
  String get detailPaymentHash => 'Hash del pago';

  @override
  String get copyPaymentHash => 'Copiar hash del pago';

  @override
  String get paymentHashCopied => 'Hash del pago copiado';

  @override
  String get detailTxid => 'ID de la transacción';

  @override
  String get copyTxid => 'Copiar ID de la transacción';

  @override
  String get txidCopied => 'ID de la transacción copiado';

  @override
  String get paymentTitle => 'Pago';

  @override
  String get paymentNotFound => 'Lumen ya no tiene este pago.';

  @override
  String get copyPreimage => 'Copiar preimagen';

  @override
  String get preimageCopied => 'Preimagen copiada';

  @override
  String get shareReceipt => 'Compartir recibo';

  @override
  String get receiptPreimage => 'Preimagen';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get liquidAddress => 'Dirección Liquid';

  @override
  String get lightningInvoice => 'Factura Lightning';

  @override
  String sendAmount(String amount) {
    return 'Enviar $amount sats';
  }

  @override
  String get sendingPayment => 'Enviando';

  @override
  String get editPayment => 'Editar pago';

  @override
  String get paymentSent => 'Pago enviado';

  @override
  String sentTo(String label) {
    return 'Para $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Pago enviado: $amount sats desde $name';
  }

  @override
  String get errorToEmpty =>
      'Pega una factura Lightning o una dirección Lightning.';

  @override
  String get errorToEmptyLiquid => 'Pega una dirección Liquid.';

  @override
  String get errorToEmptyAll =>
      'Pega una factura Lightning, una dirección Lightning o una dirección Liquid.';

  @override
  String get errorToUnrecognized =>
      'Esto no es una factura ni una dirección Lightning. Una factura empieza por lnbc, una dirección tiene el formato nombre@ejemplo.com.';

  @override
  String get errorToUnrecognizedLiquid =>
      'Esto no es una dirección Liquid. Vuelve a copiarla del destinatario, completa.';

  @override
  String get errorToUnrecognizedAll =>
      'Esto no es una factura ni una dirección que Lumen pueda pagar. Una factura empieza por lnbc, una dirección Lightning tiene el formato nombre@ejemplo.com, una dirección Liquid empieza por lq1.';

  @override
  String get errorInvoiceNoAmount =>
      'Esta factura deja el importe abierto, y Lumen aún no puede pagarla. Pide al destinatario una factura con importe.';

  @override
  String get errorWrongNetwork =>
      'Esta es una dirección de la testnet de Liquid. Pide al destinatario una dirección de la red principal de Liquid.';

  @override
  String get errorUnsupportedAsset =>
      'Esta solicitud es de un activo de Liquid distinto de L-BTC, que Lumen aún no puede enviar. Pide al destinatario una dirección para L-BTC.';

  @override
  String get errorNoWalletPaysAddress =>
      'Ninguna de tus billeteras puede pagar a una dirección Liquid. Pide al destinatario una factura o una dirección Lightning.';

  @override
  String get errorNoWalletPaysInvoice =>
      'Ninguna de tus billeteras puede pagar una factura o una dirección Lightning. Pide al destinatario una dirección Liquid.';

  @override
  String get errorInvoiceExpired =>
      'Esta factura caducó. Pide una nueva al destinatario.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label acepta de $min a $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen no pudo conectar con $label. Comprueba la dirección y tu conexión, y vuelve a intentarlo.';
  }

  @override
  String recipientRefused(String label) {
    return '$label no puede recibir pagos en este momento. Comprueba la dirección con el destinatario.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label envió una factura por otro importe, así que Lumen no la pagó.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name tiene $balance sats, no es suficiente para este pago. Paga desde otra billetera o reduce el importe.';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen no pudo conectar con $name, así que no se envió nada. Comprueba que esté en línea y vuelve a intentarlo.';
  }

  @override
  String get sendNoPermission =>
      'Esta conexión no puede pagar. En tu billetera, crea una nueva conexión que permita pagos.';

  @override
  String sendInsufficientBalance(String name) {
    return '$name no tiene suficientes sats para este pago y su comisión. Paga desde otra billetera o reduce el importe.';
  }

  @override
  String get sendBudgetExceeded =>
      'Esta conexión agotó su presupuesto de gasto. Auméntalo en los ajustes NWC de tu billetera o paga desde otra billetera.';

  @override
  String get sendFailed =>
      'El pago no se completó, a menudo por falta de una ruta hasta el destinatario. Vuelve a intentarlo más tarde o paga desde otra billetera.';

  @override
  String sendUnconfirmed(String name) {
    return '$name no confirmó el pago a tiempo. Puede que aún se complete: revisa su actividad reciente antes de volver a intentarlo.';
  }

  @override
  String get sendChainUnreachable =>
      'Lumen no pudo conectar con el servidor Liquid, así que no se envió nada. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get sendChainFailed =>
      'La red Liquid no aceptó este pago, así que no se envió nada. Vuelve a intentarlo más tarde o paga desde otra billetera.';

  @override
  String sendChainUnconfirmed(String name) {
    return 'El servidor Liquid no confirmó que recibió el pago. Puede que aún se complete: revisa la actividad reciente de $name antes de volver a intentarlo.';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get security => 'Seguridad';

  @override
  String get general => 'General';

  @override
  String get language => 'Idioma';

  @override
  String get deviceLanguage => 'Idioma del dispositivo';

  @override
  String get appLock => 'Bloqueo de la app';

  @override
  String get appLockHint =>
      'Pide tu frase de contraseña al abrir Lumen y cifra tus billeteras con ella';

  @override
  String get changePassphrase => 'Cambiar frase de contraseña';

  @override
  String get lockNow => 'Bloquear ahora';

  @override
  String keyboardShortcut(String keys) {
    return 'Atajo de teclado: $keys';
  }

  @override
  String get turnOnAppLock => 'Activar el bloqueo de la app';

  @override
  String get passphraseLead =>
      'Elige una frase de contraseña de al menos 12 caracteres. Unas cuantas palabras sin relación entre sí son largas y fáciles de recordar.';

  @override
  String get passphraseWarning =>
      'Si la olvidas, la única forma de volver a entrar es restablecer Lumen, lo que quita tus billeteras de este dispositivo. Tus fondos siguen en tus servicios de billetera.';

  @override
  String get passphraseLabel => 'Frase de contraseña';

  @override
  String get newPassphraseLabel => 'Nueva frase de contraseña';

  @override
  String get confirmPassphraseLabel => 'Escríbela de nuevo';

  @override
  String get currentPassphraseLabel => 'Frase de contraseña actual';

  @override
  String get showPassphrase => 'Mostrar frase de contraseña';

  @override
  String get hidePassphrase => 'Ocultar frase de contraseña';

  @override
  String get turnOn => 'Activar';

  @override
  String get errorPassphraseShort =>
      'Usa al menos 12 caracteres. Unas cuantas palabras seguidas son fáciles de recordar.';

  @override
  String get errorPassphraseMismatch =>
      'Las dos frases de contraseña no coinciden. Escribe la misma dos veces.';

  @override
  String get errorPassphraseWrong =>
      'Esta no es tu frase de contraseña. Revísala y vuelve a intentarlo.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Demasiadas frases de contraseña incorrectas. Vuelve a intentarlo en $count segundos.',
      one: 'Demasiadas frases de contraseña incorrectas. Vuelve a intentarlo en 1 segundo.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Demasiadas frases de contraseña incorrectas. Vuelve a intentarlo en $count minutos.',
      one: 'Demasiadas frases de contraseña incorrectas. Vuelve a intentarlo en 1 minuto.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'Lumen no pudo guardar tu frase de contraseña. Vuelve a intentarlo.';

  @override
  String get turnOffTitle => '¿Desactivar el bloqueo de la app?';

  @override
  String get turnOffBody =>
      'Lumen se abrirá sin frase de contraseña y tus billeteras dejarán de estar cifradas.';

  @override
  String get turnOff => 'Desactivar';

  @override
  String get lockedTitle => 'Lumen está bloqueado';

  @override
  String get lockedLead =>
      'Introduce tu frase de contraseña para abrir tus billeteras.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get forgotPassphrase => '¿Olvidaste tu frase de contraseña?';

  @override
  String get resetTitle => '¿Restablecer Lumen?';

  @override
  String get resetBody =>
      'Lumen quita tus billeteras y el bloqueo de la app de este dispositivo. Tus fondos siguen en tus servicios de billetera: vuelve a añadir cada billetera con su cadena de conexión.';

  @override
  String get reset => 'Restablecer';

  @override
  String get errorPassphraseEmpty => 'Introduce tu frase de contraseña.';

  @override
  String get scan => 'Escanear';

  @override
  String get scanQrCode => 'Escanear un código QR';

  @override
  String get scanHint => 'Apunta la cámara a un código QR.';

  @override
  String get turnOnLight => 'Encender la linterna';

  @override
  String get turnOffLight => 'Apagar la linterna';

  @override
  String get cameraNeeded =>
      'Permite que Lumen use la cámara para escanear códigos QR. También puedes cerrar esta pantalla y pegar el texto.';

  @override
  String get allowCamera => 'Permitir cámara';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get noCamera =>
      'No hay ninguna cámara disponible. Cierra esta pantalla y pega el texto.';

  @override
  String get addWalletLead =>
      'Crea una billetera nueva o restaura una que ya tengas.';

  @override
  String get addLightningTitle => 'Billetera Lightning';

  @override
  String get addLightningBody =>
      'Conecta un nodo o un servicio de billetera con Nostr Wallet Connect (NIP-47).';

  @override
  String get addLiquidBody =>
      'Transferencias rápidas y confidenciales en la sidechain Liquid. Lumen guarda sus claves.';

  @override
  String get liquidStartTitle => 'Billetera Liquid';

  @override
  String get liquidStartLead =>
      'Lumen crea la billetera y guarda sus claves en este dispositivo. Una frase de recuperación de 12 palabras te permite recuperarla.';

  @override
  String get liquidPointFast =>
      'Los pagos se confirman en un minuto aproximadamente';

  @override
  String get liquidPointConfidential =>
      'Los importes quedan ocultos para quien observe la cadena';

  @override
  String get liquidPointKeys => 'Tus claves se quedan en tu dispositivo';

  @override
  String get createLiquidWallet => 'Crear una billetera nueva';

  @override
  String get newLiquidTitle => 'Nueva billetera Liquid';

  @override
  String get phraseIntroHeading => 'Primero, tu frase de recuperación';

  @override
  String get phraseIntroBody =>
      'Lumen te mostrará 12 palabras. Son la única forma de recuperar esta billetera si pierdes o restableces este dispositivo, y cualquiera que las tenga puede gastar sus fondos.';

  @override
  String get phrasePointPaper => 'Escríbelas en papel, en orden';

  @override
  String get phrasePointOffline =>
      'Guárdalas sin conexión: ni capturas de pantalla, ni fotos, ni notas en la nube';

  @override
  String get phrasePointNeverAsked =>
      'Lumen solo te las pide para restaurar una billetera';

  @override
  String get showPhrase => 'Mostrar las 12 palabras';

  @override
  String get liquidUnavailable =>
      'Lumen no pudo iniciar Liquid en este dispositivo. Inténtalo más tarde.';

  @override
  String get phraseTitle => 'Frase de recuperación';

  @override
  String get phraseLead =>
      'Escribe estas 12 palabras en papel, en este orden. Después escribirás tres de ellas.';

  @override
  String phraseWord(int number, int total, String word) {
    return 'Palabra $number de $total, $word';
  }

  @override
  String get phraseWrittenDown => 'Ya las escribí';

  @override
  String get checkPhraseTitle => 'Comprueba tu frase';

  @override
  String get checkPhraseLead =>
      'Escribe estas palabras desde tu papel, para asegurarte de que son correctas.';

  @override
  String wordLabel(int number, int total) {
    return 'Palabra $number de $total';
  }

  @override
  String errorWordEmpty(int number) {
    return 'Escribe la palabra $number de tu papel.';
  }

  @override
  String errorWordMismatch(int number) {
    return 'Esta no es la palabra $number. Revisa tu papel y vuelve a escribirla.';
  }

  @override
  String wordSuggestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugerencias',
      one: '1 sugerencia',
    );
    return '$_temp0';
  }

  @override
  String get showWordsAgain => 'Ver las palabras otra vez';

  @override
  String get testnet => 'Testnet';

  @override
  String get testnetHint =>
      'Solo para pruebas. Las monedas de testnet no tienen valor.';

  @override
  String get createWallet => 'Crear billetera';

  @override
  String get errorSaveWallet =>
      'Lumen no pudo guardar la billetera. Inténtalo de nuevo.';

  @override
  String get restoreLiquidWallet => 'Restaurar una billetera';

  @override
  String get restoreLiquidTitle => 'Restaurar una billetera Liquid';

  @override
  String get restoreLead =>
      'Escribe las palabras de tu frase de recuperación, en orden. También puedes pegar la frase entera en el primer campo.';

  @override
  String get errorWordUnknown =>
      'Esta palabra no está en la lista de frases de recuperación. Revisa cómo está escrita.';

  @override
  String get errorPhraseChecksum =>
      'Estas palabras no forman una frase de recuperación. Puede que una sea incorrecta o esté fuera de lugar: compara cada una con tu papel.';

  @override
  String get restoreScanning =>
      'Buscando los pagos de esta billetera. Puede tardar un minuto.';

  @override
  String get restoreWallet => 'Restaurar billetera';

  @override
  String get errorRestoreUnreachable =>
      'Lumen no pudo conectar con el servidor Liquid para buscar los pagos de esta billetera. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get errorRestoreDuplicate => 'Esta billetera ya está en Lumen.';

  @override
  String wordsPasted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras rellenadas',
      one: '1 palabra rellenada',
    );
    return '$_temp0';
  }

  @override
  String get phraseLength => 'Longitud de la frase';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras',
      one: '1 palabra',
    );
    return '$_temp0';
  }

  @override
  String get gettingAddress => 'Obteniendo una dirección';

  @override
  String get addressUnavailable =>
      'Lumen no pudo obtener una dirección de esta billetera. Comprueba tu conexión y vuelve a intentarlo.';

  @override
  String get liquidQrLabel =>
      'Código QR de la dirección Liquid. La dirección está debajo, con un botón para copiarla.';

  @override
  String liquidAmountQrLabel(String amount) {
    return 'Código QR de la dirección Liquid por $amount sats. La dirección está debajo, con un botón para copiarla.';
  }

  @override
  String addressText(String groups) {
    return 'Dirección $groups';
  }

  @override
  String get addAmount => 'Añadir importe';

  @override
  String get amountOptional =>
      'Opcional. Déjalo vacío para recibir cualquier importe.';

  @override
  String get showQrCode => 'Mostrar código QR';

  @override
  String get waitingForConfirmation => 'Esperando la confirmación';

  @override
  String get confirmsSoon => 'Normalmente en menos de 2 minutos';

  @override
  String get paymentConfirmed => 'Confirmado';

  @override
  String get paymentConfirmedAnnouncement => 'Pago confirmado';

  @override
  String get transactionPending => 'Pendiente';

  @override
  String get detailConfirmations => 'Confirmaciones';

  @override
  String viewOnExplorer(String site) {
    return 'Ver en $site';
  }

  @override
  String explorerFailed(String site) {
    return 'Lumen no pudo abrir $site. Copia el ID de la transacción y búscalo allí.';
  }

  @override
  String get showRecoveryPhrase => 'Mostrar frase de recuperación';

  @override
  String get showPhraseTitle => '¿Mostrar la frase de recuperación?';

  @override
  String get showPhraseBody =>
      'Quien vea u oiga estas palabras puede gastar los fondos de esta billetera. Comprueba que nadie pueda ver tu pantalla ni oír tu lector de pantalla.';

  @override
  String get show => 'Mostrar';

  @override
  String savedPhraseLead(String name) {
    return 'Estas palabras restauran $name en Lumen o en otra app de Liquid. Guárdalas en papel, en este orden.';
  }

  @override
  String get removeLiquidBody =>
      'Lumen borra de este dispositivo la frase de recuperación de esta billetera. Sin tu propia copia de las palabras, sus fondos se pierden para siempre.';

  @override
  String get phraseSavedCheck =>
      'Tengo mi propia copia de la frase de recuperación';

  @override
  String get errorPhraseNotSaved =>
      'Marca esta casilla cuando tengas tu propia copia de la frase de recuperación.';

  @override
  String get servers => 'Servidores';

  @override
  String get testnetServers => 'Servidores de testnet';

  @override
  String get serversDefault => 'Predeterminados';

  @override
  String get serversCustom => 'Personalizados';

  @override
  String get liquidServersTitle => 'Servidores de Liquid';

  @override
  String get liquidTestnetServersTitle => 'Servidores de Liquid testnet';

  @override
  String get serversLead =>
      'Tus billeteras Liquid se sincronizan y envían sus pagos a través de estos servidores, primero Waterfalls. Sincroniza una billetera en una sola petición, pero su servidor puede ver cada pago que la billetera envía o recibe.';

  @override
  String get waterfallsLabel => 'URL de Waterfalls';

  @override
  String get waterfallsHint =>
      'Déjalo vacío para usar solo Esplora, que es más lento.';

  @override
  String get esploraLabel => 'URL de Esplora';

  @override
  String get esploraHint =>
      'Se usa cuando Waterfalls está vacío o no responde.';

  @override
  String get errorServerUrl =>
      'Introduce una URL completa, como https://liquid.network/api';

  @override
  String get errorEsploraEmpty =>
      'Introduce una URL de Esplora, como https://liquid.network/api';

  @override
  String get useDefaultServers => 'Usar los servidores predeterminados';

  @override
  String get defaultServersFilled => 'Servidores predeterminados rellenados';

  @override
  String get errorServersSave =>
      'Lumen no pudo guardar los servidores. Inténtalo de nuevo.';
}
