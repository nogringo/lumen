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
  String get paste => 'Pegar';

  @override
  String get payFrom => 'Pagar desde';

  @override
  String get chooseWalletThatPays => 'Elige la billetera que paga';

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
  String get shareReceipt => 'Compartir recibo';

  @override
  String get receiptPreimage => 'Preimagen';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

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
  String get errorToUnrecognized =>
      'Esto no es una factura ni una dirección Lightning. Una factura empieza por lnbc, una dirección tiene el formato nombre@ejemplo.com.';

  @override
  String get errorInvoiceNoAmount =>
      'Esta factura deja el importe abierto, y Lumen aún no puede pagarla. Pide al destinatario una factura con importe.';

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
}
