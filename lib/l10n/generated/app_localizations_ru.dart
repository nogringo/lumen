// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get tagline => 'Все ваши биткоины в одном месте.';

  @override
  String get supportedWallets => 'Поддерживаемые кошельки';

  @override
  String get kindLightning => 'Lightning';

  @override
  String get kindEcash => 'Ecash';

  @override
  String get kindOnchain => 'On-chain';

  @override
  String get kindLiquid => 'Liquid';

  @override
  String get lightningViaNwc => 'Lightning через NWC';

  @override
  String get addAWallet => 'Добавить кошелёк';

  @override
  String get add => 'Добавить';

  @override
  String get addWallet => 'Добавить кошелёк';

  @override
  String get back => 'Назад';

  @override
  String get connectNwcTitle => 'Подключение через NWC';

  @override
  String get connectNwcLead =>
      'Скопируйте строку подключения из настроек NWC вашего кошелька.';

  @override
  String get connectionStringLabel => 'Строка подключения';

  @override
  String get connectionStringHint => 'Начинается с nostr+walletconnect://';

  @override
  String get nameLabel => 'Название';

  @override
  String get connect => 'Подключить';

  @override
  String get errorUriEmpty =>
      'Вставьте строку подключения из настроек NWC вашего кошелька.';

  @override
  String get errorUriNotNwc =>
      'Это не строка подключения NWC. Она должна начинаться с nostr+walletconnect://';

  @override
  String get errorUriIncomplete =>
      'Строка подключения неполная. Скопируйте её из кошелька ещё раз, целиком.';

  @override
  String get errorUriDuplicate => 'Этот кошелёк уже есть в Lumen.';

  @override
  String get grantChecking => 'Проверяем, что разрешает это подключение';

  @override
  String get grantUnreachable =>
      'Lumen не удалось связаться с кошельком, чтобы проверить, что разрешает подключение. Вы всё равно можете его подключить.';

  @override
  String get grantCan => 'Это подключение может';

  @override
  String get grantCannot => 'Это подключение не может';

  @override
  String get grantAllowed => 'Разрешено';

  @override
  String get grantDenied => 'Не разрешено';

  @override
  String get abilityReadBalance => 'Видеть баланс';

  @override
  String get abilityReceive => 'Создавать счета';

  @override
  String get abilityPay => 'Оплачивать счета';

  @override
  String get abilityListTransactions => 'Показывать список транзакций';

  @override
  String budgetPerDay(String amount) {
    return 'До $amount sats в день';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'До $amount sats в неделю';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'До $amount sats в месяц';
  }

  @override
  String budgetPerYear(String amount) {
    return 'До $amount sats в год';
  }

  @override
  String budgetTotal(String amount) {
    return 'До $amount sats всего';
  }

  @override
  String get balanceNoPermission =>
      'Это подключение не может читать баланс. Создайте в кошельке новое подключение с правом чтения баланса.';

  @override
  String get errorNameEmpty => 'Укажите название кошелька.';

  @override
  String get overview => 'Обзор';

  @override
  String get totalBalance => 'Общий баланс';

  @override
  String get wallets => 'Кошельки';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'Загрузка баланса';

  @override
  String get balanceUnavailable => 'Недоступно';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count кошелька не учтены: их балансы недоступны.',
      many: '$count кошельков не учтены: их балансы недоступны.',
      few: '$count кошелька не учтены: их балансы недоступны.',
      one: '$count кошелёк не учтён: его баланс недоступен.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable =>
      'Lumen не удалось связаться с этим кошельком.';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get copyConnection => 'Скопировать строку подключения';

  @override
  String get copyConnectionTitle => 'Скопировать строку подключения?';

  @override
  String get copyConnectionBody =>
      'Любой, у кого она есть, может пользоваться этим кошельком как Lumen, в том числе платить, если подключение это разрешает. Вставляйте её только в приложение, которому доверяете.';

  @override
  String get copy => 'Скопировать';

  @override
  String get connectionCopied => 'Строка подключения скопирована.';

  @override
  String walletOptions(String name) {
    return 'Параметры кошелька $name';
  }

  @override
  String get rename => 'Переименовать';

  @override
  String get remove => 'Удалить';

  @override
  String get renameTitle => 'Переименовать кошелёк';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String removeTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String get removeBody =>
      'Lumen забудет это подключение. Кошелёк и его средства не затрагиваются, и вы сможете подключить его снова позже.';

  @override
  String get refreshBalances => 'Обновить балансы';

  @override
  String get refreshBalance => 'Обновить баланс';

  @override
  String get receive => 'Получить';

  @override
  String get receiveInto => 'Куда';

  @override
  String get chooseWallet => 'Выберите кошелёк для получения';

  @override
  String get amountLabel => 'Сумма в sats';

  @override
  String get sendEverything => 'Отправить всё';

  @override
  String sendEverythingHint(String name) {
    return 'Весь баланс кошелька $name за вычетом комиссии.';
  }

  @override
  String get createInvoice => 'Создать счёт';

  @override
  String get creatingInvoice => 'Создание счёта';

  @override
  String get errorAmountEmpty => 'Введите сумму не меньше 1 sat.';

  @override
  String get receiveUnreachable =>
      'Lumen не удалось получить счёт от этого кошелька. Проверьте, что он в сети, и попробуйте снова.';

  @override
  String get receiveNoPermission =>
      'Это подключение не может создавать счета. Создайте в кошельке новое подключение с правом получения платежей.';

  @override
  String invoiceQrLabel(String amount) {
    return 'QR-код счёта Lightning на $amount sats. Текст счёта ниже, рядом кнопка копирования.';
  }

  @override
  String invoiceText(String text) {
    return 'Счёт $text';
  }

  @override
  String get editAmount => 'Изменить сумму';

  @override
  String get copyInvoice => 'Скопировать счёт';

  @override
  String get invoiceCopied => 'Счёт скопирован';

  @override
  String get shareInvoice => 'Поделиться счётом';

  @override
  String get lightningAddress => 'Lightning-адрес';

  @override
  String get copyAddress => 'Скопировать адрес';

  @override
  String get addressCopied => 'Адрес скопирован';

  @override
  String get showAddressQr => 'Показать QR-код';

  @override
  String addressQrLabel(String address) {
    return 'QR-код Lightning-адреса $address';
  }

  @override
  String get shareAddress => 'Поделиться адресом';

  @override
  String get waitingForPayment => 'Ожидание платежа';

  @override
  String get expiresSoon => 'Истекает меньше чем через минуту';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Истекает через $minutes минуты',
      many: 'Истекает через $minutes минут',
      few: 'Истекает через $minutes минуты',
      one: 'Истекает через $minutes минуту',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Истекает через $hours часа',
      many: 'Истекает через $hours часов',
      few: 'Истекает через $hours часа',
      one: 'Истекает через $hours час',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'Срок действия счёта истёк. Создайте новый, чтобы получить этот платёж.';

  @override
  String get newInvoice => 'Новый счёт';

  @override
  String get paymentReceived => 'Платёж получен';

  @override
  String receivedInto(String name) {
    return 'В кошелёк $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Платёж получен: $amount sats в кошелёк $name';
  }

  @override
  String get done => 'Готово';

  @override
  String get close => 'Закрыть';

  @override
  String get recentActivity => 'Недавняя активность';

  @override
  String get activityLoading => 'Загрузка активности';

  @override
  String get noActivity => 'Платежей пока нет.';

  @override
  String get activityUnreachable =>
      'Lumen не удалось загрузить активность этого кошелька.';

  @override
  String get activityNoPermission =>
      'Это подключение не может получать список транзакций. Создайте в кошельке новое подключение с правом просмотра транзакций.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Активность $count кошелька не показана: её не удалось загрузить.',
      many: 'Активность $count кошельков не показана: её не удалось загрузить.',
      few: 'Активность $count кошельков не показана: её не удалось загрузить.',
      one: 'Активность $count кошелька не показана: её не удалось загрузить.',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Показать все';

  @override
  String get seeAllActivity => 'Показать всю активность';

  @override
  String get activityTitle => 'Активность';

  @override
  String walletActivityTitle(String name) {
    return 'Активность: $name';
  }

  @override
  String get showMore => 'Показать ещё';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показано $count платежа',
      many: 'Показано $count платежей',
      few: 'Показано $count платежа',
      one: 'Показан $count платёж',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => 'Загрузка более ранних платежей';

  @override
  String get activityEnd => 'Это все платежи, которые сохранил Lumen.';

  @override
  String get transactionReceived => 'Получено';

  @override
  String get transactionSent => 'Отправлено';

  @override
  String amountReceived(String amount) {
    return 'получено $amount sats';
  }

  @override
  String amountSent(String amount) {
    return 'отправлено $amount sats';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet, $when';
  }

  @override
  String get justNow => 'Только что';

  @override
  String minutesAgo(int minutes) {
    return '$minutes мин назад';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ч назад';
  }

  @override
  String get yesterday => 'Вчера';

  @override
  String get columnDescription => 'Описание';

  @override
  String get columnWallet => 'Кошелёк';

  @override
  String get columnDate => 'Дата';

  @override
  String get columnAmount => 'Сумма';

  @override
  String get send => 'Отправить';

  @override
  String get sendTo => 'Кому';

  @override
  String get sendToHint => 'Счёт Lightning или адрес Lightning';

  @override
  String get sendToHintLiquid => 'Адрес Liquid';

  @override
  String get sendToHintAll =>
      'Счёт Lightning, адрес Lightning или адрес Liquid';

  @override
  String get paste => 'Вставить';

  @override
  String get payFrom => 'Списать с';

  @override
  String get chooseWalletThatPays => 'Выберите кошелёк для оплаты';

  @override
  String get amountSetByLink => 'Сумма указана в ссылке';

  @override
  String get amountSetByInvoice => 'Сумма указана в счёте';

  @override
  String get reviewPayment => 'Проверить';

  @override
  String get checkingPayment => 'Проверка';

  @override
  String get youAreSending => 'Вы отправляете';

  @override
  String get detailTo => 'Кому';

  @override
  String get detailNote => 'Примечание';

  @override
  String get detailFrom => 'Откуда';

  @override
  String get detailNetwork => 'Сеть';

  @override
  String get detailFee => 'Комиссия';

  @override
  String get detailFeePaid => 'Комиссия';

  @override
  String get detailDate => 'Дата';

  @override
  String get detailPaymentHash => 'Хеш платежа';

  @override
  String get copyPaymentHash => 'Скопировать хеш платежа';

  @override
  String get paymentHashCopied => 'Хеш платежа скопирован';

  @override
  String get detailTxid => 'ID транзакции';

  @override
  String get copyTxid => 'Скопировать ID транзакции';

  @override
  String get txidCopied => 'ID транзакции скопирован';

  @override
  String get paymentTitle => 'Платёж';

  @override
  String get paymentNotFound => 'Этого платежа больше нет в Lumen.';

  @override
  String get copyPreimage => 'Скопировать прообраз';

  @override
  String get preimageCopied => 'Прообраз скопирован';

  @override
  String get shareReceipt => 'Поделиться квитанцией';

  @override
  String get receiptPreimage => 'Прообраз';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get liquidAddress => 'Адрес Liquid';

  @override
  String get lightningInvoice => 'Счёт Lightning';

  @override
  String sendAmount(String amount) {
    return 'Отправить $amount sats';
  }

  @override
  String get sendingPayment => 'Отправка';

  @override
  String get editPayment => 'Изменить платёж';

  @override
  String get paymentSent => 'Платёж отправлен';

  @override
  String sentTo(String label) {
    return 'Кому: $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Платёж отправлен: $amount sats с кошелька $name';
  }

  @override
  String get errorToEmpty => 'Вставьте счёт Lightning или адрес Lightning.';

  @override
  String get errorToEmptyLiquid => 'Вставьте адрес Liquid.';

  @override
  String get errorToEmptyAll =>
      'Вставьте счёт Lightning, адрес Lightning или адрес Liquid.';

  @override
  String get errorToUnrecognized =>
      'Это не счёт и не адрес Lightning. Счёт начинается с lnbc, адрес выглядит как name@example.com.';

  @override
  String get errorToUnrecognizedLiquid =>
      'Это не адрес Liquid. Скопируйте его у получателя ещё раз, целиком.';

  @override
  String get errorToUnrecognizedAll =>
      'Это не счёт и не адрес, который Lumen может оплатить. Счёт начинается с lnbc, адрес Lightning выглядит как name@example.com, адрес Liquid начинается с lq1.';

  @override
  String get errorInvoiceNoAmount =>
      'В этом счёте не указана сумма, а такие счета Lumen пока не умеет оплачивать. Попросите получателя выставить счёт с суммой.';

  @override
  String get errorWrongNetwork =>
      'Это адрес тестовой сети Liquid. Попросите получателя дать адрес основной сети Liquid.';

  @override
  String get errorUnsupportedAsset =>
      'Этот запрос на актив Liquid, отличный от L-BTC, а такие Lumen пока не умеет отправлять. Попросите получателя дать адрес для L-BTC.';

  @override
  String get errorNoWalletPaysAddress =>
      'Ни один из ваших кошельков не может платить на адрес Liquid. Попросите получателя дать счёт или адрес Lightning.';

  @override
  String get errorNoWalletPaysInvoice =>
      'Ни один из ваших кошельков не может оплатить счёт или адрес Lightning. Попросите получателя дать адрес Liquid.';

  @override
  String get errorInvoiceExpired =>
      'Срок действия счёта истёк. Попросите получателя выставить новый.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label принимает от $min до $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen не удалось связаться с $label. Проверьте адрес и подключение к сети, затем попробуйте снова.';
  }

  @override
  String recipientRefused(String label) {
    return '$label сейчас не может принимать платежи. Уточните адрес у получателя.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return 'От $label пришёл счёт на другую сумму, поэтому Lumen не стал его оплачивать.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return 'В кошельке $name $balance sats, для этого платежа не хватает. Оплатите с другого кошелька или уменьшите сумму.';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen не удалось связаться с кошельком $name, поэтому ничего не отправлено. Проверьте, что он в сети, и попробуйте снова.';
  }

  @override
  String get sendNoPermission =>
      'Это подключение не может проводить платежи. Создайте в кошельке новое подключение с правом оплаты.';

  @override
  String sendInsufficientBalance(String name) {
    return 'В кошельке $name не хватает sats на этот платёж с комиссией. Оплатите с другого кошелька или уменьшите сумму.';
  }

  @override
  String get sendBudgetExceeded =>
      'Это подключение исчерпало лимит расходов. Увеличьте его в настройках NWC кошелька или оплатите с другого кошелька.';

  @override
  String get sendFailed =>
      'Платёж не прошёл, часто из-за отсутствия маршрута к получателю. Попробуйте позже или оплатите с другого кошелька.';

  @override
  String sendUnconfirmed(String name) {
    return 'Кошелёк $name не подтвердил платёж вовремя. Платёж ещё может пройти: проверьте недавнюю активность кошелька, прежде чем повторять.';
  }

  @override
  String get sendChainUnreachable =>
      'Lumen не удалось связаться с сервером Liquid, поэтому ничего не отправлено. Проверьте подключение и попробуйте снова.';

  @override
  String get sendChainFailed =>
      'Сеть Liquid не приняла этот платёж, поэтому ничего не отправлено. Попробуйте позже или оплатите с другого кошелька.';

  @override
  String sendChainUnconfirmed(String name) {
    return 'Сервер Liquid не подтвердил, что получил платёж. Платёж ещё может пройти: проверьте недавнюю активность кошелька $name, прежде чем повторять.';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get security => 'Безопасность';

  @override
  String get general => 'Общие';

  @override
  String get language => 'Язык';

  @override
  String get deviceLanguage => 'Язык устройства';

  @override
  String get appLock => 'Блокировка приложения';

  @override
  String get appLockHint =>
      'Запрашивает парольную фразу при открытии Lumen и шифрует ею ваши кошельки';

  @override
  String get changePassphrase => 'Сменить парольную фразу';

  @override
  String get lockNow => 'Заблокировать сейчас';

  @override
  String keyboardShortcut(String keys) {
    return 'Сочетание клавиш: $keys';
  }

  @override
  String get turnOnAppLock => 'Включить блокировку приложения';

  @override
  String get passphraseLead =>
      'Выберите парольную фразу длиной не менее 12 символов. Несколько не связанных между собой слов дают длинную фразу, которую легко запомнить.';

  @override
  String get passphraseWarning =>
      'Если вы её забудете, вернуться можно будет только через сброс Lumen, а он удалит ваши кошельки с этого устройства. Ваши средства останутся у сервисов ваших кошельков.';

  @override
  String get passphraseLabel => 'Парольная фраза';

  @override
  String get newPassphraseLabel => 'Новая парольная фраза';

  @override
  String get confirmPassphraseLabel => 'Введите её ещё раз';

  @override
  String get currentPassphraseLabel => 'Текущая парольная фраза';

  @override
  String get showPassphrase => 'Показать парольную фразу';

  @override
  String get hidePassphrase => 'Скрыть парольную фразу';

  @override
  String get turnOn => 'Включить';

  @override
  String get errorPassphraseShort =>
      'Используйте не менее 12 символов. Несколько слов подряд легко запомнить.';

  @override
  String get errorPassphraseMismatch =>
      'Парольные фразы не совпадают. Введите одну и ту же дважды.';

  @override
  String get errorPassphraseWrong =>
      'Неверная парольная фраза. Проверьте её и попробуйте снова.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Слишком много неверных попыток. Попробуйте снова через $count секунды.',
      many:
          'Слишком много неверных попыток. Попробуйте снова через $count секунд.',
      few:
          'Слишком много неверных попыток. Попробуйте снова через $count секунды.',
      one:
          'Слишком много неверных попыток. Попробуйте снова через $count секунду.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Слишком много неверных попыток. Попробуйте снова через $count минуты.',
      many:
          'Слишком много неверных попыток. Попробуйте снова через $count минут.',
      few:
          'Слишком много неверных попыток. Попробуйте снова через $count минуты.',
      one:
          'Слишком много неверных попыток. Попробуйте снова через $count минуту.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'Lumen не удалось сохранить парольную фразу. Попробуйте снова.';

  @override
  String get turnOffTitle => 'Отключить блокировку приложения?';

  @override
  String get turnOffBody =>
      'Lumen будет открываться без парольной фразы, а ваши кошельки больше не будут зашифрованы.';

  @override
  String get turnOff => 'Отключить';

  @override
  String get lockedTitle => 'Lumen заблокирован';

  @override
  String get lockedLead => 'Введите парольную фразу, чтобы открыть кошельки.';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get forgotPassphrase => 'Забыли парольную фразу?';

  @override
  String get resetTitle => 'Сбросить Lumen?';

  @override
  String get resetBody =>
      'Lumen удалит ваши кошельки и блокировку приложения с этого устройства. Ваши средства останутся у сервисов ваших кошельков: добавьте каждый кошелёк заново с его строкой подключения.';

  @override
  String get reset => 'Сбросить';

  @override
  String get errorPassphraseEmpty => 'Введите парольную фразу.';

  @override
  String get scan => 'Сканировать';

  @override
  String get scanQrCode => 'Сканировать QR-код';

  @override
  String get scanHint => 'Наведите камеру на QR-код.';

  @override
  String get turnOnLight => 'Включить фонарик';

  @override
  String get turnOffLight => 'Выключить фонарик';

  @override
  String get cameraNeeded =>
      'Разрешите Lumen использовать камеру для сканирования QR-кодов. Также можно закрыть этот экран и вставить текст.';

  @override
  String get allowCamera => 'Разрешить доступ к камере';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get noCamera =>
      'Камера недоступна. Закройте этот экран и вставьте текст.';

  @override
  String get addWalletLead =>
      'Создайте новый кошелёк или восстановите существующий.';

  @override
  String get addLightningTitle => 'Кошелёк Lightning';

  @override
  String get addLightningBody =>
      'Подключите узел или сервис кошелька через Nostr Wallet Connect (NIP-47).';

  @override
  String get addLiquidBody =>
      'Быстрые конфиденциальные переводы в сайдчейне Liquid. Ключи хранит Lumen.';

  @override
  String get liquidStartTitle => 'Кошелёк Liquid';

  @override
  String get liquidStartLead =>
      'Lumen создаёт кошелёк и хранит его ключи на этом устройстве. Фраза восстановления из 12 слов позволит вернуть его.';

  @override
  String get liquidPointFast => 'Платежи подтверждаются примерно за минуту';

  @override
  String get liquidPointConfidential =>
      'Суммы скрыты от всех, кто наблюдает за блокчейном';

  @override
  String get liquidPointKeys => 'Ваши ключи остаются на вашем устройстве';

  @override
  String get createLiquidWallet => 'Создать новый кошелёк';

  @override
  String get newLiquidTitle => 'Новый кошелёк Liquid';

  @override
  String get phraseIntroHeading => 'Сначала фраза восстановления';

  @override
  String get phraseIntroBody =>
      'Lumen покажет 12 слов. Только с ними можно вернуть этот кошелёк, если вы потеряете или сбросите это устройство, и любой, у кого они есть, может потратить его средства.';

  @override
  String get phrasePointPaper => 'Запишите их на бумаге по порядку';

  @override
  String get phrasePointOffline =>
      'Храните их офлайн: без снимков экрана, фото и заметок в облаке';

  @override
  String get phrasePointNeverAsked =>
      'Lumen просит их только для восстановления кошелька';

  @override
  String get showPhrase => 'Показать 12 слов';

  @override
  String get liquidUnavailable =>
      'Lumen не удалось запустить Liquid на этом устройстве. Повторите попытку позже.';

  @override
  String get phraseTitle => 'Фраза восстановления';

  @override
  String get phraseLead =>
      'Запишите эти 12 слов на бумаге в этом порядке. Затем вы введёте три из них.';

  @override
  String phraseWord(int number, int total, String word) {
    return 'Слово $number из $total, $word';
  }

  @override
  String get phraseWrittenDown => 'Я записал слова';

  @override
  String get checkPhraseTitle => 'Проверка фразы';

  @override
  String get checkPhraseLead =>
      'Введите эти слова со своей бумаги, чтобы убедиться, что они записаны верно.';

  @override
  String wordLabel(int number, int total) {
    return 'Слово $number из $total';
  }

  @override
  String errorWordEmpty(int number) {
    return 'Введите слово $number со своей бумаги.';
  }

  @override
  String errorWordMismatch(int number) {
    return 'Это не слово $number. Проверьте запись и введите его снова.';
  }

  @override
  String wordSuggestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подсказки',
      many: '$count подсказок',
      few: '$count подсказки',
      one: '1 подсказка',
    );
    return '$_temp0';
  }

  @override
  String get showWordsAgain => 'Показать слова снова';

  @override
  String get testnet => 'Testnet';

  @override
  String get testnetHint =>
      'Только для тестирования. Монеты testnet ничего не стоят.';

  @override
  String get createWallet => 'Создать кошелёк';

  @override
  String get errorSaveWallet =>
      'Lumen не удалось сохранить кошелёк. Повторите попытку.';

  @override
  String get restoreLiquidWallet => 'Восстановить кошелёк';

  @override
  String get restoreLiquidTitle => 'Восстановление кошелька Liquid';

  @override
  String get restoreLead =>
      'Введите слова фразы восстановления по порядку. Можно также вставить всю фразу в первое поле.';

  @override
  String get errorWordUnknown =>
      'Этого слова нет в списке слов для фраз восстановления. Проверьте написание.';

  @override
  String get errorPhraseChecksum =>
      'Эти слова не образуют фразу восстановления. Возможно, одно из них неверно или стоит не на своём месте: сверьте каждое с записью.';

  @override
  String get restoreScanning =>
      'Поиск платежей этого кошелька. Это может занять минуту.';

  @override
  String get restoreWallet => 'Восстановить кошелёк';

  @override
  String get errorRestoreUnreachable =>
      'Lumen не удалось связаться с сервером Liquid, чтобы найти платежи этого кошелька. Проверьте подключение и повторите попытку.';

  @override
  String get errorRestoreDuplicate => 'Этот кошелёк уже есть в Lumen.';

  @override
  String wordsPasted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Заполнено $count слова',
      many: 'Заполнено $count слов',
      few: 'Заполнено $count слова',
      one: 'Заполнено 1 слово',
    );
    return '$_temp0';
  }

  @override
  String get phraseLength => 'Длина фразы';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count слова',
      many: '$count слов',
      few: '$count слова',
      one: '1 слово',
    );
    return '$_temp0';
  }

  @override
  String get gettingAddress => 'Получение адреса';

  @override
  String get addressUnavailable =>
      'Lumen не удалось получить адрес от этого кошелька. Проверьте подключение и попробуйте снова.';

  @override
  String get liquidQrLabel =>
      'QR-код адреса Liquid. Адрес ниже, рядом кнопка копирования.';

  @override
  String liquidAmountQrLabel(String amount) {
    return 'QR-код адреса Liquid на $amount sats. Адрес ниже, рядом кнопка копирования.';
  }

  @override
  String addressText(String groups) {
    return 'Адрес $groups';
  }

  @override
  String get addAmount => 'Указать сумму';

  @override
  String get amountOptional =>
      'Необязательно. Оставьте пустым, чтобы получить любую сумму.';

  @override
  String get showQrCode => 'Показать QR-код';

  @override
  String get waitingForConfirmation => 'Ожидание подтверждения';

  @override
  String get confirmsSoon => 'Обычно в течение 2 минут';

  @override
  String get paymentConfirmed => 'Подтверждено';

  @override
  String get paymentConfirmedAnnouncement => 'Платёж подтверждён';

  @override
  String get transactionPending => 'В ожидании';

  @override
  String get detailConfirmations => 'Подтверждения';

  @override
  String viewOnExplorer(String site) {
    return 'Открыть на $site';
  }

  @override
  String explorerFailed(String site) {
    return 'Lumen не удалось открыть $site. Скопируйте ID транзакции и найдите его там.';
  }

  @override
  String get showRecoveryPhrase => 'Показать фразу восстановления';

  @override
  String get showPhraseTitle => 'Показать фразу восстановления?';

  @override
  String get showPhraseBody =>
      'Любой, кто увидит или услышит эти слова, сможет потратить средства этого кошелька. Убедитесь, что никто не видит ваш экран и не слышит программу чтения с экрана.';

  @override
  String get show => 'Показать';

  @override
  String savedPhraseLead(String name) {
    return 'Эти слова восстанавливают кошелёк $name в Lumen или другом приложении Liquid. Храните их на бумаге в этом порядке.';
  }
}
