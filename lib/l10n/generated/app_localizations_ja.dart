// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get tagline => 'あなたのすべてのビットコインを、ひとつの場所に。';

  @override
  String get supportedWallets => '対応ウォレット';

  @override
  String get kindLightning => 'Lightning';

  @override
  String get kindEcash => 'Ecash';

  @override
  String get kindOnchain => 'オンチェーン';

  @override
  String get kindLiquid => 'Liquid';

  @override
  String get lightningViaNwc => 'NWC 経由の Lightning';

  @override
  String get addAWallet => 'ウォレットを追加';

  @override
  String get add => '追加';

  @override
  String get addWallet => 'ウォレットを追加';

  @override
  String get back => '戻る';

  @override
  String get connectNwcTitle => 'NWC で接続';

  @override
  String get connectNwcLead => 'ウォレットの NWC 設定から接続文字列をコピーしてください。';

  @override
  String get connectionStringLabel => '接続文字列';

  @override
  String get connectionStringHint => 'nostr+walletconnect:// で始まります';

  @override
  String get nameLabel => '名前';

  @override
  String get connect => '接続';

  @override
  String get errorUriEmpty => 'ウォレットの NWC 設定から接続文字列を貼り付けてください。';

  @override
  String get errorUriNotNwc =>
      'NWC の接続文字列ではありません。nostr+walletconnect:// で始まる必要があります。';

  @override
  String get errorUriIncomplete => 'この接続文字列は不完全です。ウォレットからもう一度、全体をコピーしてください。';

  @override
  String get errorUriDuplicate => 'このウォレットはすでに Lumen に追加されています。';

  @override
  String get grantChecking => 'この接続で許可されている内容を確認しています';

  @override
  String get grantUnreachable =>
      '接続で許可されている内容を確認するためにこのウォレットに接続できませんでした。このまま接続することもできます。';

  @override
  String get grantCan => 'この接続でできること';

  @override
  String get grantCannot => 'この接続でできないこと';

  @override
  String get grantAllowed => '許可';

  @override
  String get grantDenied => '不許可';

  @override
  String get abilityReadBalance => '残高を見る';

  @override
  String get abilityReceive => 'インボイスを作成する';

  @override
  String get abilityPay => 'インボイスを支払う';

  @override
  String get abilityListTransactions => '取引を一覧表示する';

  @override
  String budgetPerDay(String amount) {
    return '1日あたり最大 $amount sats';
  }

  @override
  String budgetPerWeek(String amount) {
    return '1週間あたり最大 $amount sats';
  }

  @override
  String budgetPerMonth(String amount) {
    return '1か月あたり最大 $amount sats';
  }

  @override
  String budgetPerYear(String amount) {
    return '1年あたり最大 $amount sats';
  }

  @override
  String budgetTotal(String amount) {
    return '合計で最大 $amount sats';
  }

  @override
  String get balanceNoPermission =>
      'この接続では残高を読み取れません。ウォレットで、残高の読み取りを許可する新しい接続を作成してください。';

  @override
  String get errorNameEmpty => 'このウォレットに名前を付けてください。';

  @override
  String get overview => '概要';

  @override
  String get totalBalance => '合計残高';

  @override
  String get wallets => 'ウォレット';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => '残高を読み込み中';

  @override
  String get balanceUnavailable => '取得できません';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のウォレットは残高を取得できないため、合計に含まれていません。',
      one: '1 件のウォレットは残高を取得できないため、合計に含まれていません。',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable => 'Lumen はこのウォレットに接続できませんでした。';

  @override
  String get tryAgain => '再試行';

  @override
  String get copyConnection => '接続文字列をコピー';

  @override
  String get copyConnectionTitle => '接続文字列をコピーしますか？';

  @override
  String get copyConnectionBody =>
      'これを持つ人は誰でも、Lumen と同じようにこのウォレットを使えます。接続で許可されていれば支払いもできます。信頼できるアプリにだけ貼り付けてください。';

  @override
  String get copy => 'コピー';

  @override
  String get connectionCopied => '接続文字列をコピーしました。';

  @override
  String walletOptions(String name) {
    return '$name のオプション';
  }

  @override
  String get rename => '名前を変更';

  @override
  String get remove => '削除';

  @override
  String get renameTitle => 'ウォレット名を変更';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String removeTitle(String name) {
    return '$name を削除しますか？';
  }

  @override
  String get removeBody => 'Lumen はこの接続を削除します。ウォレットとその資金には影響せず、あとで再接続できます。';

  @override
  String get refreshBalances => '残高を更新';

  @override
  String get refreshBalance => '残高を更新';

  @override
  String get receive => '受け取る';

  @override
  String get receiveInto => '受取先';

  @override
  String get chooseWallet => '受け取るウォレットを選択';

  @override
  String get amountLabel => '金額（sats）';

  @override
  String get sendEverything => 'すべて送金';

  @override
  String sendEverythingHint(String name) {
    return '$name の残高すべてから手数料を差し引いた額。';
  }

  @override
  String get createInvoice => 'インボイスを作成';

  @override
  String get creatingInvoice => 'インボイスを作成中';

  @override
  String get errorAmountEmpty => '1 sat 以上の金額を入力してください。';

  @override
  String get receiveUnreachable =>
      'Lumen はこのウォレットからインボイスを取得できませんでした。オンラインであることを確認して、もう一度お試しください。';

  @override
  String get receiveNoPermission =>
      'この接続ではインボイスを作成できません。ウォレットで、支払いの受け取りを許可する新しい接続を作成してください。';

  @override
  String invoiceQrLabel(String amount) {
    return '$amount sats の Lightning インボイスの QR コード。インボイスの文字列はこの下にあり、コピーボタンが付いています。';
  }

  @override
  String invoiceText(String text) {
    return 'インボイス $text';
  }

  @override
  String get editAmount => '金額を編集';

  @override
  String get copyInvoice => 'インボイスをコピー';

  @override
  String get invoiceCopied => 'インボイスをコピーしました';

  @override
  String get shareInvoice => 'インボイスを共有';

  @override
  String get lightningAddress => 'Lightning アドレス';

  @override
  String get copyAddress => 'アドレスをコピー';

  @override
  String get addressCopied => 'アドレスをコピーしました';

  @override
  String get showAddressQr => 'QR コードを表示';

  @override
  String addressQrLabel(String address) {
    return 'Lightning アドレス $address の QR コード';
  }

  @override
  String get shareAddress => 'アドレスを共有';

  @override
  String get waitingForPayment => '支払いを待っています';

  @override
  String get expiresSoon => '1 分以内に期限切れ';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'あと $minutes 分で期限切れ',
      one: 'あと 1 分で期限切れ',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'あと $hours 時間で期限切れ',
      one: 'あと 1 時間で期限切れ',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired => 'このインボイスは期限切れです。この支払いを受け取るには、新しいインボイスを作成してください。';

  @override
  String get newInvoice => '新しいインボイス';

  @override
  String get paymentReceived => '支払いを受け取りました';

  @override
  String receivedInto(String name) {
    return '受取先：$name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return '支払いを受け取りました：$amount sats、受取先は $name';
  }

  @override
  String get done => '完了';

  @override
  String get close => '閉じる';

  @override
  String get recentActivity => '最近のアクティビティ';

  @override
  String get activityLoading => 'アクティビティを読み込み中';

  @override
  String get noActivity => 'まだ支払いはありません。';

  @override
  String get activityUnreachable => 'Lumen はこのウォレットのアクティビティを読み込めませんでした。';

  @override
  String get activityNoPermission =>
      'この接続では取引を一覧表示できません。ウォレットで、取引の一覧表示を許可する新しい接続を作成してください。';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のウォレットのアクティビティは読み込めなかったため、表示されていません。',
      one: '1 件のウォレットのアクティビティは読み込めなかったため、表示されていません。',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'すべて表示';

  @override
  String get seeAllActivity => 'すべてのアクティビティを表示';

  @override
  String get activityTitle => 'アクティビティ';

  @override
  String walletActivityTitle(String name) {
    return '$name のアクティビティ';
  }

  @override
  String get showMore => 'さらに表示';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の支払いを表示中',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => '以前の支払いを読み込み中';

  @override
  String get activityEnd => 'Lumen が保存した支払いはこれですべてです。';

  @override
  String get transactionReceived => '受け取り';

  @override
  String get transactionSent => '送金';

  @override
  String amountReceived(String amount) {
    return '$amount sats を受け取り';
  }

  @override
  String amountSent(String amount) {
    return '$amount sats を送金';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet、$when';
  }

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int minutes) {
    return '$minutes 分前';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours 時間前';
  }

  @override
  String get yesterday => '昨日';

  @override
  String get columnDescription => '説明';

  @override
  String get columnWallet => 'ウォレット';

  @override
  String get columnDate => '日付';

  @override
  String get columnAmount => '金額';

  @override
  String get send => '送る';

  @override
  String get sendTo => '送金先';

  @override
  String get sendToHint => 'Lightning インボイスまたは Lightning アドレス';

  @override
  String get sendToHintLiquid => 'Liquid アドレス';

  @override
  String get sendToHintAll => 'Lightning インボイス、Lightning アドレス、または Liquid アドレス';

  @override
  String get paste => '貼り付け';

  @override
  String get payFrom => '支払い元';

  @override
  String get chooseWalletThatPays => '支払うウォレットを選択';

  @override
  String get amountSetByLink => 'リンクで指定された金額';

  @override
  String get amountSetByInvoice => 'インボイスで指定された金額';

  @override
  String get reviewPayment => '確認';

  @override
  String get checkingPayment => '確認中';

  @override
  String get youAreSending => '送金額';

  @override
  String get detailTo => '送金先';

  @override
  String get detailNote => 'メモ';

  @override
  String get detailFrom => '支払い元';

  @override
  String get detailNetwork => 'ネットワーク';

  @override
  String get detailFee => '手数料';

  @override
  String get detailFeePaid => '支払った手数料';

  @override
  String get detailDate => '日時';

  @override
  String get detailPaymentHash => '支払いハッシュ';

  @override
  String get copyPaymentHash => '支払いハッシュをコピー';

  @override
  String get paymentHashCopied => '支払いハッシュをコピーしました';

  @override
  String get detailTxid => 'トランザクション ID';

  @override
  String get copyTxid => 'トランザクション ID をコピー';

  @override
  String get txidCopied => 'トランザクション ID をコピーしました';

  @override
  String get paymentTitle => '支払い';

  @override
  String get paymentNotFound => 'この支払いは Lumen に残っていません。';

  @override
  String get copyPreimage => 'プリイメージをコピー';

  @override
  String get preimageCopied => 'プリイメージをコピーしました';

  @override
  String get shareReceipt => '領収書を共有';

  @override
  String get receiptPreimage => 'プリイメージ';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get liquidAddress => 'Liquid アドレス';

  @override
  String get lightningInvoice => 'Lightning インボイス';

  @override
  String sendAmount(String amount) {
    return '$amount sats を送る';
  }

  @override
  String get sendingPayment => '送金中';

  @override
  String get editPayment => '支払いを編集';

  @override
  String get paymentSent => '送金しました';

  @override
  String sentTo(String label) {
    return '送金先：$label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return '送金しました：$amount sats、支払い元は $name';
  }

  @override
  String get errorToEmpty => 'Lightning インボイスまたは Lightning アドレスを貼り付けてください。';

  @override
  String get errorToEmptyLiquid => 'Liquid アドレスを貼り付けてください。';

  @override
  String get errorToEmptyAll =>
      'Lightning インボイス、Lightning アドレス、または Liquid アドレスを貼り付けてください。';

  @override
  String get errorToUnrecognized =>
      'Lightning インボイスでもアドレスでもありません。インボイスは lnbc で始まり、アドレスは name@example.com のような形式です。';

  @override
  String get errorToUnrecognizedLiquid =>
      'Liquid アドレスではありません。受取人からもう一度、全体をコピーしてください。';

  @override
  String get errorToUnrecognizedAll =>
      'Lumen が支払えるインボイスでもアドレスでもありません。インボイスは lnbc で始まり、Lightning アドレスは name@example.com のような形式で、Liquid アドレスは lq1 で始まります。';

  @override
  String get errorInvoiceNoAmount =>
      'このインボイスは金額が指定されていないため、Lumen ではまだ支払えません。金額入りのインボイスを受取人に依頼してください。';

  @override
  String get errorWrongNetwork =>
      'これは Liquid テストネットのアドレスです。Liquid メインネットのアドレスを受取人に依頼してください。';

  @override
  String get errorUnsupportedAsset =>
      'このリクエストは L-BTC 以外の Liquid アセットを求めており、Lumen ではまだ送れません。L-BTC 用のアドレスを受取人に依頼してください。';

  @override
  String get errorNoWalletPaysAddress =>
      'Liquid アドレスに支払えるウォレットがありません。代わりに Lightning インボイスかアドレスを受取人に依頼してください。';

  @override
  String get errorNoWalletPaysInvoice =>
      'Lightning インボイスやアドレスに支払えるウォレットがありません。代わりに Liquid アドレスを受取人に依頼してください。';

  @override
  String get errorInvoiceExpired => 'このインボイスは期限切れです。受取人に新しいインボイスを依頼してください。';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label が受け付ける金額は $min から $max sats です。';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen は $label に接続できませんでした。アドレスとネットワーク接続を確認して、もう一度お試しください。';
  }

  @override
  String recipientRefused(String label) {
    return '$label は現在支払いを受け取れません。受取人にアドレスを確認してください。';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label から別の金額のインボイスが届いたため、Lumen は支払いませんでした。';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name の残高は $balance sats で、この支払いには足りません。別のウォレットから支払うか、金額を減らしてください。';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen は $name に接続できなかったため、何も送金されていません。オンラインであることを確認して、もう一度お試しください。';
  }

  @override
  String get sendNoPermission =>
      'この接続では支払いができません。ウォレットで、支払いを許可する新しい接続を作成してください。';

  @override
  String sendInsufficientBalance(String name) {
    return '$name の残高は、この支払いと手数料には足りません。別のウォレットから支払うか、金額を減らしてください。';
  }

  @override
  String get sendBudgetExceeded =>
      'この接続は支出上限に達しました。ウォレットの NWC 設定で上限を引き上げるか、別のウォレットから支払ってください。';

  @override
  String get sendFailed =>
      '支払いが完了しませんでした。多くの場合、受取人へのルートが見つからないことが原因です。あとでもう一度試すか、別のウォレットから支払ってください。';

  @override
  String sendUnconfirmed(String name) {
    return '$name が時間内に支払いを確認しませんでした。支払いはまだ完了する可能性があります。もう一度試す前に、最近のアクティビティを確認してください。';
  }

  @override
  String get sendChainUnreachable =>
      'Lumen は Liquid サーバーに接続できなかったため、何も送金されていません。接続を確認して、もう一度お試しください。';

  @override
  String get sendChainFailed =>
      'Liquid ネットワークがこの支払いを受け付けなかったため、何も送金されていません。あとでもう一度試すか、別のウォレットから支払ってください。';

  @override
  String sendChainUnconfirmed(String name) {
    return 'Liquid サーバーが支払いの受信を確認しませんでした。支払いはまだ完了する可能性があります。もう一度試す前に、$name の最近のアクティビティを確認してください。';
  }

  @override
  String get settings => '設定';

  @override
  String get security => 'セキュリティ';

  @override
  String get general => '一般';

  @override
  String get language => '言語';

  @override
  String get deviceLanguage => '端末の言語';

  @override
  String get appLock => 'アプリロック';

  @override
  String get appLockHint => 'Lumen を開くときにパスフレーズを求め、そのパスフレーズでウォレットを暗号化します';

  @override
  String get changePassphrase => 'パスフレーズを変更';

  @override
  String get lockNow => '今すぐロック';

  @override
  String keyboardShortcut(String keys) {
    return 'キーボードショートカット: $keys';
  }

  @override
  String get turnOnAppLock => 'アプリロックをオンにする';

  @override
  String get passphraseLead =>
      '12 文字以上のパスフレーズを選んでください。関係のない単語をいくつか並べると、長くて覚えやすくなります。';

  @override
  String get passphraseWarning =>
      'パスフレーズを忘れた場合、Lumen をリセットするしかなく、この端末からウォレットが削除されます。資金はウォレットサービスに残ります。';

  @override
  String get passphraseLabel => 'パスフレーズ';

  @override
  String get newPassphraseLabel => '新しいパスフレーズ';

  @override
  String get confirmPassphraseLabel => 'もう一度入力';

  @override
  String get currentPassphraseLabel => '現在のパスフレーズ';

  @override
  String get showPassphrase => 'パスフレーズを表示';

  @override
  String get hidePassphrase => 'パスフレーズを隠す';

  @override
  String get turnOn => 'オンにする';

  @override
  String get errorPassphraseShort => '12 文字以上にしてください。単語をいくつか並べると覚えやすくなります。';

  @override
  String get errorPassphraseMismatch => '2 つのパスフレーズが一致しません。同じものを 2 回入力してください。';

  @override
  String get errorPassphraseWrong => 'パスフレーズが違います。確認して、もう一度お試しください。';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'パスフレーズの誤りが多すぎます。$count 秒後にもう一度お試しください。',
      one: 'パスフレーズの誤りが多すぎます。1 秒後にもう一度お試しください。',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'パスフレーズの誤りが多すぎます。$count 分後にもう一度お試しください。',
      one: 'パスフレーズの誤りが多すぎます。1 分後にもう一度お試しください。',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave => 'Lumen はパスフレーズを保存できませんでした。もう一度お試しください。';

  @override
  String get turnOffTitle => 'アプリロックをオフにしますか？';

  @override
  String get turnOffBody => 'Lumen はパスフレーズなしで開くようになり、ウォレットは暗号化されなくなります。';

  @override
  String get turnOff => 'オフにする';

  @override
  String get lockedTitle => 'Lumen はロックされています';

  @override
  String get lockedLead => 'ウォレットを開くにはパスフレーズを入力してください。';

  @override
  String get unlock => 'ロックを解除';

  @override
  String get forgotPassphrase => 'パスフレーズを忘れた場合';

  @override
  String get resetTitle => 'Lumen をリセットしますか？';

  @override
  String get resetBody =>
      'Lumen はこの端末からウォレットとアプリロックを削除します。資金はウォレットサービスに残ります。各ウォレットを接続文字列でもう一度追加してください。';

  @override
  String get reset => 'リセット';

  @override
  String get errorPassphraseEmpty => 'パスフレーズを入力してください。';

  @override
  String get scan => 'スキャン';

  @override
  String get scanQrCode => 'QRコードをスキャン';

  @override
  String get scanHint => 'カメラをQRコードに向けてください。';

  @override
  String get turnOnLight => 'ライトをオン';

  @override
  String get turnOffLight => 'ライトをオフ';

  @override
  String get cameraNeeded =>
      'QRコードをスキャンするには、Lumenにカメラの使用を許可してください。この画面を閉じてテキストを貼り付けることもできます。';

  @override
  String get allowCamera => 'カメラを許可';

  @override
  String get openSettings => '設定を開く';

  @override
  String get noCamera => '使用できるカメラがありません。この画面を閉じてテキストを貼り付けてください。';

  @override
  String get addWalletLead => '新しいウォレットを作成するか、お持ちのウォレットを復元します。';

  @override
  String get addLightningTitle => 'Lightning ウォレット';

  @override
  String get addLightningBody =>
      'Nostr Wallet Connect (NIP-47) でノードやウォレットサービスに接続します。';

  @override
  String get addLiquidBody => 'Liquid サイドチェーンで高速かつ秘匿性の高い送金。鍵は Lumen が保管します。';

  @override
  String get liquidStartTitle => 'Liquid ウォレット';

  @override
  String get liquidStartLead =>
      'Lumen がウォレットを作成し、鍵をこのデバイスに保管します。12 語のリカバリーフレーズで復元できます。';

  @override
  String get liquidPointFast => '支払いは約 1 分で承認されます';

  @override
  String get liquidPointConfidential => '金額はチェーンを見ている人から隠されます';

  @override
  String get liquidPointKeys => '鍵はあなたのデバイスに保管されます';

  @override
  String get createLiquidWallet => '新しいウォレットを作成';

  @override
  String get newLiquidTitle => '新しい Liquid ウォレット';

  @override
  String get phraseIntroHeading => 'まず、リカバリーフレーズ';

  @override
  String get phraseIntroBody =>
      'Lumen が 12 個の単語を表示します。このデバイスを紛失したりリセットしたりしたとき、ウォレットを取り戻す唯一の方法です。単語を知っている人は誰でも資金を使えます。';

  @override
  String get phrasePointPaper => '順番どおりに紙に書き留める';

  @override
  String get phrasePointOffline => 'オフラインで保管する。スクリーンショット、写真、クラウドのメモは使わない';

  @override
  String get phrasePointNeverAsked => 'Lumen が単語を求めるのはウォレットの復元時だけです';

  @override
  String get showPhrase => '12 個の単語を表示';

  @override
  String get liquidUnavailable => 'このデバイスで Liquid を起動できませんでした。あとでもう一度お試しください。';

  @override
  String get phraseTitle => 'リカバリーフレーズ';

  @override
  String get phraseLead => 'この 12 個の単語を、この順番で紙に書き留めてください。次にそのうち 3 つを入力します。';

  @override
  String phraseWord(int number, int total, String word) {
    return '$total 語中 $number 番目、$word';
  }

  @override
  String get phraseWrittenDown => '書き留めました';

  @override
  String get checkPhraseTitle => 'フレーズの確認';

  @override
  String get checkPhraseLead => '紙に書いた単語を入力して、正しいか確認してください。';

  @override
  String wordLabel(int number, int total) {
    return '$total 語中 $number 番目';
  }

  @override
  String errorWordEmpty(int number) {
    return '紙に書いた $number 番目の単語を入力してください。';
  }

  @override
  String errorWordMismatch(int number) {
    return '$number 番目の単語ではありません。紙を確認して、もう一度入力してください。';
  }

  @override
  String wordSuggestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '候補 $count 件',
    );
    return '$_temp0';
  }

  @override
  String get showWordsAgain => '単語をもう一度表示';

  @override
  String get testnet => 'テストネット';

  @override
  String get testnetHint => 'テスト専用です。テストネットのコインには価値がありません。';

  @override
  String get createWallet => 'ウォレットを作成';

  @override
  String get errorSaveWallet => 'ウォレットを保存できませんでした。もう一度お試しください。';

  @override
  String get restoreLiquidWallet => 'ウォレットを復元';

  @override
  String get restoreLiquidTitle => 'Liquid ウォレットを復元';

  @override
  String get restoreLead =>
      'リカバリーフレーズの単語を順番に入力してください。フレーズ全体を最初の欄に貼り付けることもできます。';

  @override
  String get errorWordUnknown => 'この単語はリカバリーフレーズの単語リストにありません。綴りを確認してください。';

  @override
  String get errorPhraseChecksum =>
      'これらの単語はリカバリーフレーズになっていません。どれかが間違っているか、順番が違う可能性があります。紙と 1 つずつ照らし合わせてください。';

  @override
  String get restoreScanning => 'このウォレットの支払いを探しています。1 分ほどかかることがあります。';

  @override
  String get restoreWallet => 'ウォレットを復元';

  @override
  String get errorRestoreUnreachable =>
      'このウォレットの支払いを探すために Liquid サーバーに接続できませんでした。接続を確認して、もう一度お試しください。';

  @override
  String get errorRestoreDuplicate => 'このウォレットはすでに Lumen にあります。';

  @override
  String wordsPasted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個の単語を入力しました',
    );
    return '$_temp0';
  }

  @override
  String get phraseLength => 'フレーズの長さ';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 語',
    );
    return '$_temp0';
  }

  @override
  String get gettingAddress => 'アドレスを取得中';

  @override
  String get addressUnavailable =>
      'Lumen はこのウォレットからアドレスを取得できませんでした。接続を確認して、もう一度お試しください。';

  @override
  String get liquidQrLabel => 'Liquid アドレスの QR コード。アドレスはこの下にあり、コピーボタンが付いています。';

  @override
  String liquidAmountQrLabel(String amount) {
    return '$amount sats の Liquid アドレスの QR コード。アドレスはこの下にあり、コピーボタンが付いています。';
  }

  @override
  String addressText(String groups) {
    return 'アドレス $groups';
  }

  @override
  String get addAmount => '金額を追加';

  @override
  String get amountOptional => '任意です。空欄のままにすると、どの金額でも受け取れます。';

  @override
  String get showQrCode => 'QR コードを表示';

  @override
  String get waitingForConfirmation => '承認を待っています';

  @override
  String get confirmsSoon => '通常 2 分以内';

  @override
  String get paymentConfirmed => '承認済み';

  @override
  String get paymentConfirmedAnnouncement => '支払いが承認されました';

  @override
  String get transactionPending => '承認待ち';
}
