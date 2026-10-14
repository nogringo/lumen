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
  String get paste => '貼り付け';

  @override
  String get payFrom => '支払い元';

  @override
  String get chooseWalletThatPays => '支払うウォレットを選択';

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
  String get shareReceipt => '領収書を共有';

  @override
  String get receiptPreimage => 'プリイメージ';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

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
  String get errorToUnrecognized =>
      'Lightning インボイスでもアドレスでもありません。インボイスは lnbc で始まり、アドレスは name@example.com のような形式です。';

  @override
  String get errorInvoiceNoAmount =>
      'このインボイスは金額が指定されていないため、Lumen ではまだ支払えません。金額入りのインボイスを受取人に依頼してください。';

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
}
