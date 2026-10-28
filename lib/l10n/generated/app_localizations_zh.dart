// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get tagline => '您持有比特币的所有方式，尽在一处。';

  @override
  String get supportedWallets => '支持的钱包';

  @override
  String get kindLightning => 'Lightning';

  @override
  String get kindEcash => 'Ecash';

  @override
  String get kindOnchain => '链上';

  @override
  String get kindLiquid => 'Liquid';

  @override
  String get lightningViaNwc => 'Lightning（通过 NWC）';

  @override
  String get addAWallet => '添加钱包';

  @override
  String get add => '添加';

  @override
  String get addWallet => '添加钱包';

  @override
  String get back => '返回';

  @override
  String get connectNwcTitle => '通过 NWC 连接';

  @override
  String get connectNwcLead => '从您钱包的 NWC 设置中复制连接字符串。';

  @override
  String get connectionStringLabel => '连接字符串';

  @override
  String get connectionStringHint => '以 nostr+walletconnect:// 开头';

  @override
  String get nameLabel => '名称';

  @override
  String get connect => '连接';

  @override
  String get errorUriEmpty => '请粘贴您钱包 NWC 设置中的连接字符串。';

  @override
  String get errorUriNotNwc => '这不是 NWC 连接字符串。它应以 nostr+walletconnect:// 开头';

  @override
  String get errorUriIncomplete => '此连接字符串不完整。请从您的钱包重新完整复制。';

  @override
  String get errorUriDuplicate => '此钱包已在 Lumen 中。';

  @override
  String get grantChecking => '正在检查此连接允许的操作';

  @override
  String get grantUnreachable => 'Lumen 无法连接此钱包以检查该连接允许的操作。您仍然可以连接它。';

  @override
  String get grantCan => '此连接可以';

  @override
  String get grantCannot => '此连接不能';

  @override
  String get grantAllowed => '允许';

  @override
  String get grantDenied => '不允许';

  @override
  String get abilityReadBalance => '查看余额';

  @override
  String get abilityReceive => '创建发票';

  @override
  String get abilityPay => '支付发票';

  @override
  String get abilityListTransactions => '列出交易';

  @override
  String budgetPerDay(String amount) {
    return '每天最多 $amount sats';
  }

  @override
  String budgetPerWeek(String amount) {
    return '每周最多 $amount sats';
  }

  @override
  String budgetPerMonth(String amount) {
    return '每月最多 $amount sats';
  }

  @override
  String budgetPerYear(String amount) {
    return '每年最多 $amount sats';
  }

  @override
  String budgetTotal(String amount) {
    return '总计最多 $amount sats';
  }

  @override
  String get balanceNoPermission => '此连接无法读取余额。请在您的钱包中新建一个允许读取余额的连接。';

  @override
  String get errorNameEmpty => '请为此钱包命名。';

  @override
  String get overview => '概览';

  @override
  String get totalBalance => '总余额';

  @override
  String get wallets => '钱包';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => '正在加载余额';

  @override
  String get balanceUnavailable => '不可用';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个钱包未计入：其余额不可用。',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable => 'Lumen 无法连接到此钱包。';

  @override
  String get tryAgain => '重试';

  @override
  String get copyConnection => '复制连接字符串';

  @override
  String get copyConnectionTitle => '复制连接字符串？';

  @override
  String get copyConnectionBody =>
      '任何拥有它的人都能像 Lumen 一样使用这个钱包，如果该连接允许，还可以付款。请只粘贴到您信任的应用中。';

  @override
  String get copy => '复制';

  @override
  String get connectionCopied => '连接字符串已复制。';

  @override
  String walletOptions(String name) {
    return '$name 选项';
  }

  @override
  String get rename => '重命名';

  @override
  String get remove => '移除';

  @override
  String get renameTitle => '重命名钱包';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String removeTitle(String name) {
    return '移除 $name？';
  }

  @override
  String get removeBody => 'Lumen 将忘记此连接。钱包及其资金不受影响，您之后可以重新连接。';

  @override
  String get refreshBalances => '刷新余额';

  @override
  String get refreshBalance => '刷新余额';

  @override
  String get receive => '收款';

  @override
  String get receiveInto => '收款至';

  @override
  String get chooseWallet => '选择收款钱包';

  @override
  String get amountLabel => '金额（sats）';

  @override
  String get sendEverything => '全部发送';

  @override
  String sendEverythingHint(String name) {
    return '$name 的全部余额，扣除手续费。';
  }

  @override
  String get createInvoice => '创建发票';

  @override
  String get creatingInvoice => '正在创建发票';

  @override
  String get errorAmountEmpty => '请输入至少 1 sat 的金额。';

  @override
  String get receiveUnreachable => 'Lumen 无法从此钱包获取发票。请确认钱包在线，然后重试。';

  @override
  String get receiveNoPermission => '此连接无法创建发票。请在您的钱包中新建一个允许收款的连接。';

  @override
  String invoiceQrLabel(String amount) {
    return '金额为 $amount sats 的 Lightning 发票二维码。发票文本在下方，附有复制按钮。';
  }

  @override
  String invoiceText(String text) {
    return '发票 $text';
  }

  @override
  String get editAmount => '修改金额';

  @override
  String get copyInvoice => '复制发票';

  @override
  String get invoiceCopied => '已复制发票';

  @override
  String get shareInvoice => '分享发票';

  @override
  String get lightningAddress => 'Lightning 地址';

  @override
  String get copyAddress => '复制地址';

  @override
  String get addressCopied => '地址已复制';

  @override
  String get showAddressQr => '显示二维码';

  @override
  String addressQrLabel(String address) {
    return 'Lightning 地址 $address 的二维码';
  }

  @override
  String get shareAddress => '分享地址';

  @override
  String get waitingForPayment => '等待付款';

  @override
  String get expiresSoon => '不到 1 分钟后过期';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes 分钟后过期',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours 小时后过期',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired => '此发票已过期。请创建新发票以接收这笔付款。';

  @override
  String get newInvoice => '新发票';

  @override
  String get paymentReceived => '已收到付款';

  @override
  String receivedInto(String name) {
    return '收款至 $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return '已收到付款：$amount sats，存入 $name';
  }

  @override
  String get done => '完成';

  @override
  String get close => '关闭';

  @override
  String get recentActivity => '最近活动';

  @override
  String get activityLoading => '正在加载活动';

  @override
  String get noActivity => '暂无付款。';

  @override
  String get activityUnreachable => 'Lumen 无法加载此钱包的活动。';

  @override
  String get activityNoPermission => '此连接无法列出交易。请在您的钱包中新建一个允许列出交易的连接。';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未显示 $count 个钱包的活动：无法加载。',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => '查看全部';

  @override
  String get seeAllActivity => '查看全部活动';

  @override
  String get activityTitle => '活动';

  @override
  String walletActivityTitle(String name) {
    return '$name 的活动';
  }

  @override
  String get showMore => '显示更多';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已显示 $count 笔付款',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => '正在加载更早的付款';

  @override
  String get activityEnd => '这些是 Lumen 保存的全部付款。';

  @override
  String get transactionReceived => '已收款';

  @override
  String get transactionSent => '已付款';

  @override
  String amountReceived(String amount) {
    return '收到 $amount sats';
  }

  @override
  String amountSent(String amount) {
    return '发送 $amount sats';
  }

  @override
  String transactionWalletWhen(String wallet, String when) {
    return '$wallet，$when';
  }

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int minutes) {
    return '$minutes 分钟前';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours 小时前';
  }

  @override
  String get yesterday => '昨天';

  @override
  String get columnDescription => '描述';

  @override
  String get columnWallet => '钱包';

  @override
  String get columnDate => '日期';

  @override
  String get columnAmount => '金额';

  @override
  String get send => '发送';

  @override
  String get sendTo => '收款方';

  @override
  String get sendToHint => 'Lightning 发票或 Lightning 地址';

  @override
  String get sendToHintLiquid => 'Liquid 地址';

  @override
  String get sendToHintAll => 'Lightning 发票、Lightning 地址或 Liquid 地址';

  @override
  String get paste => '粘贴';

  @override
  String get payFrom => '付款钱包';

  @override
  String get chooseWalletThatPays => '选择付款钱包';

  @override
  String get amountSetByLink => '金额由链接指定';

  @override
  String get amountSetByInvoice => '金额由发票指定';

  @override
  String get reviewPayment => '核对';

  @override
  String get checkingPayment => '正在核对';

  @override
  String get youAreSending => '您将发送';

  @override
  String get detailTo => '收款方';

  @override
  String get detailNote => '备注';

  @override
  String get detailFrom => '付款方';

  @override
  String get detailNetwork => '网络';

  @override
  String get detailFee => '手续费';

  @override
  String get detailFeePaid => '已付手续费';

  @override
  String get detailDate => '日期';

  @override
  String get detailPaymentHash => '支付哈希';

  @override
  String get copyPaymentHash => '复制支付哈希';

  @override
  String get paymentHashCopied => '已复制支付哈希';

  @override
  String get detailTxid => '交易 ID';

  @override
  String get copyTxid => '复制交易 ID';

  @override
  String get txidCopied => '已复制交易 ID';

  @override
  String get paymentTitle => '付款';

  @override
  String get paymentNotFound => 'Lumen 中已没有这笔付款。';

  @override
  String get copyPreimage => '复制原像';

  @override
  String get preimageCopied => '原像已复制';

  @override
  String get shareReceipt => '分享收据';

  @override
  String get receiptPreimage => '原像';

  @override
  String receiptLine(String label, String value) {
    return '$label：$value';
  }

  @override
  String get liquidAddress => 'Liquid 地址';

  @override
  String get lightningInvoice => 'Lightning 发票';

  @override
  String sendAmount(String amount) {
    return '发送 $amount sats';
  }

  @override
  String get sendingPayment => '正在发送';

  @override
  String get editPayment => '修改付款';

  @override
  String get paymentSent => '付款已发送';

  @override
  String sentTo(String label) {
    return '付给 $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return '付款已发送：$amount sats，来自 $name';
  }

  @override
  String get errorToEmpty => '请粘贴 Lightning 发票或 Lightning 地址。';

  @override
  String get errorToEmptyLiquid => '请粘贴 Liquid 地址。';

  @override
  String get errorToEmptyAll => '请粘贴 Lightning 发票、Lightning 地址或 Liquid 地址。';

  @override
  String get errorToUnrecognized =>
      '这不是 Lightning 发票或地址。发票以 lnbc 开头，地址形如 name@example.com。';

  @override
  String get errorToUnrecognizedLiquid => '这不是 Liquid 地址。请从收款方那里重新完整复制。';

  @override
  String get errorToUnrecognizedAll =>
      '这不是 Lumen 能支付的发票或地址。发票以 lnbc 开头，Lightning 地址形如 name@example.com，Liquid 地址以 lq1 开头。';

  @override
  String get errorInvoiceNoAmount => '此发票未指定金额，Lumen 暂不支持支付。请向收款方索取带金额的发票。';

  @override
  String get errorWrongNetwork => '这是 Liquid 测试网地址。请向收款方索取 Liquid 主网地址。';

  @override
  String get errorUnsupportedAsset =>
      '此请求针对 L-BTC 以外的 Liquid 资产，Lumen 暂不支持发送。请向收款方索取 L-BTC 地址。';

  @override
  String get errorNoWalletPaysAddress =>
      '你的钱包都无法向 Liquid 地址付款。请改为向收款方索取 Lightning 发票或地址。';

  @override
  String get errorNoWalletPaysInvoice =>
      '你的钱包都无法支付 Lightning 发票或地址。请改为向收款方索取 Liquid 地址。';

  @override
  String get errorInvoiceExpired => '此发票已过期。请向收款方索取新发票。';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label 接受 $min 至 $max sats。';
  }

  @override
  String recipientUnreachable(String label) {
    return 'Lumen 无法连接到 $label。请检查地址和网络连接，然后重试。';
  }

  @override
  String recipientRefused(String label) {
    return '$label 目前无法收款。请向收款方核实地址。';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label 发来的发票金额不符，因此 Lumen 没有支付。';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name 只有 $balance sats，不足以支付此笔付款。请换用其他钱包付款，或降低金额。';
  }

  @override
  String sendUnreachable(String name) {
    return 'Lumen 无法连接到 $name，因此未发送任何款项。请确认钱包在线，然后重试。';
  }

  @override
  String get sendNoPermission => '此连接无法付款。请在您的钱包中新建一个允许付款的连接。';

  @override
  String sendInsufficientBalance(String name) {
    return '$name 的 sats 不足以支付此笔付款及手续费。请换用其他钱包付款，或降低金额。';
  }

  @override
  String get sendBudgetExceeded => '此连接的支出额度已用完。请在您钱包的 NWC 设置中提高额度，或换用其他钱包付款。';

  @override
  String get sendFailed => '付款未成功，通常是因为找不到通往收款方的路由。请稍后重试，或换用其他钱包付款。';

  @override
  String sendUnconfirmed(String name) {
    return '$name 未能及时确认付款。付款可能仍会完成：重试前请先查看其最近活动。';
  }

  @override
  String get sendChainUnreachable =>
      'Lumen 无法连接 Liquid 服务器，因此未发送任何款项。请检查网络连接，然后重试。';

  @override
  String get sendChainFailed => 'Liquid 网络未接受这笔付款，因此未发送任何款项。请稍后重试，或换用其他钱包付款。';

  @override
  String sendChainUnconfirmed(String name) {
    return 'Liquid 服务器未确认收到这笔付款。付款可能仍会完成：重试前请先查看 $name 的最近活动。';
  }

  @override
  String get settings => '设置';

  @override
  String get security => '安全';

  @override
  String get general => '通用';

  @override
  String get language => '语言';

  @override
  String get deviceLanguage => '设备语言';

  @override
  String get appLock => '应用锁';

  @override
  String get appLockHint => '打开 Lumen 时要求输入密码短语，并用它加密您的钱包';

  @override
  String get changePassphrase => '更改密码短语';

  @override
  String get lockNow => '立即锁定';

  @override
  String keyboardShortcut(String keys) {
    return '键盘快捷键：$keys';
  }

  @override
  String get turnOnAppLock => '开启应用锁';

  @override
  String get passphraseLead => '请设置至少 12 个字符的密码短语。几个互不相关的词组合起来既够长又好记。';

  @override
  String get passphraseWarning =>
      '如果忘记密码短语，唯一的办法是重置 Lumen，这会从本设备移除您的钱包。您的资金仍保留在各钱包服务中。';

  @override
  String get passphraseLabel => '密码短语';

  @override
  String get newPassphraseLabel => '新密码短语';

  @override
  String get confirmPassphraseLabel => '再次输入';

  @override
  String get currentPassphraseLabel => '当前密码短语';

  @override
  String get showPassphrase => '显示密码短语';

  @override
  String get hidePassphrase => '隐藏密码短语';

  @override
  String get turnOn => '开启';

  @override
  String get errorPassphraseShort => '请至少使用 12 个字符。几个词连在一起就很好记。';

  @override
  String get errorPassphraseMismatch => '两次输入的密码短语不一致。请输入相同的密码短语。';

  @override
  String get errorPassphraseWrong => '密码短语不正确。请检查后重试。';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '密码短语错误次数过多。请在 $count 秒后重试。',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '密码短语错误次数过多。请在 $count 分钟后重试。',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave => 'Lumen 无法保存您的密码短语。请重试。';

  @override
  String get turnOffTitle => '关闭应用锁？';

  @override
  String get turnOffBody => 'Lumen 打开时将不再要求密码短语，您的钱包也将不再加密。';

  @override
  String get turnOff => '关闭';

  @override
  String get lockedTitle => 'Lumen 已锁定';

  @override
  String get lockedLead => '输入密码短语以打开您的钱包。';

  @override
  String get unlock => '解锁';

  @override
  String get forgotPassphrase => '忘记密码短语？';

  @override
  String get resetTitle => '重置 Lumen？';

  @override
  String get resetBody =>
      'Lumen 将从本设备移除您的钱包和应用锁。您的资金仍保留在各钱包服务中：请用各自的连接字符串重新添加每个钱包。';

  @override
  String get reset => '重置';

  @override
  String get errorPassphraseEmpty => '请输入您的密码短语。';

  @override
  String get scan => '扫描';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get scanHint => '将相机对准二维码。';

  @override
  String get turnOnLight => '打开手电筒';

  @override
  String get turnOffLight => '关闭手电筒';

  @override
  String get cameraNeeded => '请允许 Lumen 使用相机扫描二维码。您也可以关闭此页面并粘贴文本。';

  @override
  String get allowCamera => '允许使用相机';

  @override
  String get openSettings => '打开设置';

  @override
  String get noCamera => '没有可用的相机。请关闭此页面并粘贴文本。';

  @override
  String get addWalletLead => '创建新钱包，或恢复已有的钱包。';

  @override
  String get addLightningTitle => 'Lightning 钱包';

  @override
  String get addLightningBody => '通过 Nostr Wallet Connect (NIP-47) 连接节点或钱包服务。';

  @override
  String get addLiquidBody => '在 Liquid 侧链上快速、保密地转账。密钥由 Lumen 保管。';

  @override
  String get liquidStartTitle => 'Liquid 钱包';

  @override
  String get liquidStartLead => 'Lumen 会创建钱包，并将密钥保存在此设备上。凭 12 个单词的恢复短语即可找回钱包。';

  @override
  String get liquidPointFast => '付款约一分钟即可确认';

  @override
  String get liquidPointConfidential => '金额对观察链的人保密';

  @override
  String get liquidPointKeys => '您的密钥留在您的设备上';

  @override
  String get createLiquidWallet => '创建新钱包';

  @override
  String get newLiquidTitle => '新的 Liquid 钱包';

  @override
  String get phraseIntroHeading => '首先，您的恢复短语';

  @override
  String get phraseIntroBody =>
      'Lumen 将显示 12 个单词。如果您丢失或重置此设备，它们是找回此钱包的唯一方式，任何拥有它们的人都可以花费其中的资金。';

  @override
  String get phrasePointPaper => '按顺序写在纸上';

  @override
  String get phrasePointOffline => '离线保存：不要截图、拍照或存在云笔记中';

  @override
  String get phrasePointNeverAsked => 'Lumen 只在恢复钱包时才会要求输入';

  @override
  String get showPhrase => '显示 12 个单词';

  @override
  String get liquidUnavailable => 'Lumen 无法在此设备上启动 Liquid。请稍后再试。';

  @override
  String get phraseTitle => '恢复短语';

  @override
  String get phraseLead => '请按此顺序将这 12 个单词写在纸上。接下来您需要输入其中三个。';

  @override
  String phraseWord(int number, int total, String word) {
    return '第 $number 个单词，共 $total 个，$word';
  }

  @override
  String get phraseWrittenDown => '我已写下';

  @override
  String get checkPhraseTitle => '核对短语';

  @override
  String get checkPhraseLead => '根据您的纸张输入这些单词，确认它们无误。';

  @override
  String wordLabel(int number, int total) {
    return '第 $number 个单词，共 $total 个';
  }

  @override
  String errorWordEmpty(int number) {
    return '请输入纸上的第 $number 个单词。';
  }

  @override
  String errorWordMismatch(int number) {
    return '这不是第 $number 个单词。请核对纸张后重新输入。';
  }

  @override
  String wordSuggestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条建议',
    );
    return '$_temp0';
  }

  @override
  String get showWordsAgain => '再次显示单词';

  @override
  String get testnet => '测试网';

  @override
  String get testnetHint => '仅用于测试。测试网币没有价值。';

  @override
  String get createWallet => '创建钱包';

  @override
  String get errorSaveWallet => 'Lumen 无法保存钱包。请重试。';

  @override
  String get restoreLiquidWallet => '恢复钱包';

  @override
  String get restoreLiquidTitle => '恢复 Liquid 钱包';

  @override
  String get restoreLead => '请按顺序输入恢复短语的单词。您也可以将整个短语粘贴到第一个输入框。';

  @override
  String get errorWordUnknown => '此单词不在恢复短语的词表中。请检查拼写。';

  @override
  String get errorPhraseChecksum => '这些单词无法组成恢复短语。其中某个可能有误或位置不对：请对照纸张逐一核对。';

  @override
  String get restoreScanning => '正在查找此钱包的付款记录。这可能需要一分钟。';

  @override
  String get restoreWallet => '恢复钱包';

  @override
  String get errorRestoreUnreachable =>
      'Lumen 无法连接 Liquid 服务器来查找此钱包的付款记录。请检查网络连接后重试。';

  @override
  String get errorRestoreDuplicate => '此钱包已在 Lumen 中。';

  @override
  String wordsPasted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已填入 $count 个单词',
    );
    return '$_temp0';
  }

  @override
  String get phraseLength => '短语长度';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个单词',
    );
    return '$_temp0';
  }

  @override
  String get gettingAddress => '正在获取地址';

  @override
  String get addressUnavailable => 'Lumen 无法从此钱包获取地址。请检查网络连接，然后重试。';

  @override
  String get liquidQrLabel => 'Liquid 地址二维码。地址在下方，附有复制按钮。';

  @override
  String liquidAmountQrLabel(String amount) {
    return '金额为 $amount sats 的 Liquid 地址二维码。地址在下方，附有复制按钮。';
  }

  @override
  String addressText(String groups) {
    return '地址 $groups';
  }

  @override
  String get addAmount => '添加金额';

  @override
  String get amountOptional => '选填。留空即可接收任意金额。';

  @override
  String get showQrCode => '显示二维码';

  @override
  String get waitingForConfirmation => '等待确认';

  @override
  String get confirmsSoon => '通常在 2 分钟内';

  @override
  String get paymentConfirmed => '已确认';

  @override
  String get paymentConfirmedAnnouncement => '付款已确认';

  @override
  String get transactionPending => '待确认';
}
