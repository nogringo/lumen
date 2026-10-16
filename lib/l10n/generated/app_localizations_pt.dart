// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get tagline => 'Todas as formas de guardar bitcoin, num só lugar.';

  @override
  String get supportedWallets => 'Carteiras suportadas';

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
  String get addAWallet => 'Adicionar uma carteira';

  @override
  String get add => 'Adicionar';

  @override
  String get addWallet => 'Adicionar carteira';

  @override
  String get back => 'Voltar';

  @override
  String get connectNwcTitle => 'Ligar com NWC';

  @override
  String get connectNwcLead =>
      'Copie a cadeia de ligação das definições NWC da sua carteira.';

  @override
  String get connectionStringLabel => 'Cadeia de ligação';

  @override
  String get connectionStringHint => 'Começa por nostr+walletconnect://';

  @override
  String get nameLabel => 'Nome';

  @override
  String get connect => 'Ligar';

  @override
  String get errorUriEmpty =>
      'Cole a cadeia de ligação das definições NWC da sua carteira.';

  @override
  String get errorUriNotNwc =>
      'Isto não é uma cadeia de ligação NWC. Deve começar por nostr+walletconnect://';

  @override
  String get errorUriIncomplete =>
      'Esta cadeia de ligação está incompleta. Copie-a novamente da sua carteira, por inteiro.';

  @override
  String get errorUriDuplicate => 'Esta carteira já está no Lumen.';

  @override
  String get grantChecking => 'A verificar o que esta ligação permite';

  @override
  String get grantUnreachable =>
      'O Lumen não conseguiu contactar esta carteira para verificar o que a ligação permite. Pode ligá-la mesmo assim.';

  @override
  String get grantCan => 'Esta ligação pode';

  @override
  String get grantCannot => 'Esta ligação não pode';

  @override
  String get grantAllowed => 'Permitido';

  @override
  String get grantDenied => 'Não permitido';

  @override
  String get abilityReadBalance => 'Ver o saldo';

  @override
  String get abilityReceive => 'Criar faturas';

  @override
  String get abilityPay => 'Pagar faturas';

  @override
  String get abilityListTransactions => 'Listar transações';

  @override
  String budgetPerDay(String amount) {
    return 'Até $amount sats por dia';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'Até $amount sats por semana';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'Até $amount sats por mês';
  }

  @override
  String budgetPerYear(String amount) {
    return 'Até $amount sats por ano';
  }

  @override
  String budgetTotal(String amount) {
    return 'Até $amount sats no total';
  }

  @override
  String get balanceNoPermission =>
      'Esta ligação não pode ler o saldo. Na sua carteira, crie uma nova ligação que permita ler o saldo.';

  @override
  String get errorNameEmpty => 'Dê um nome a esta carteira.';

  @override
  String get overview => 'Visão geral';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get wallets => 'Carteiras';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'A carregar o saldo';

  @override
  String get balanceUnavailable => 'Indisponível';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count carteiras não são contabilizadas: os seus saldos estão indisponíveis.',
      one: '1 carteira não é contabilizada: o seu saldo está indisponível.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable =>
      'O Lumen não conseguiu contactar esta carteira.';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get copyConnection => 'Copiar cadeia de ligação';

  @override
  String get copyConnectionTitle => 'Copiar a cadeia de ligação?';

  @override
  String get copyConnectionBody =>
      'Quem a tiver pode usar esta carteira como o Lumen, incluindo pagar se esta ligação o permitir. Cole-a apenas numa app em que confie.';

  @override
  String get copy => 'Copiar';

  @override
  String get connectionCopied => 'Cadeia de ligação copiada.';

  @override
  String walletOptions(String name) {
    return 'Opções de $name';
  }

  @override
  String get rename => 'Mudar o nome';

  @override
  String get remove => 'Remover';

  @override
  String get renameTitle => 'Mudar o nome da carteira';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String removeTitle(String name) {
    return 'Remover $name?';
  }

  @override
  String get removeBody =>
      'O Lumen esquece esta ligação. A carteira e os seus fundos não são afetados, e pode voltar a ligá-la mais tarde.';

  @override
  String get refreshBalances => 'Atualizar saldos';

  @override
  String get refreshBalance => 'Atualizar saldo';

  @override
  String get receive => 'Receber';

  @override
  String get receiveInto => 'Para';

  @override
  String get chooseWallet => 'Escolher a carteira que recebe';

  @override
  String get amountLabel => 'Montante em sats';

  @override
  String get createInvoice => 'Criar fatura';

  @override
  String get creatingInvoice => 'A criar fatura';

  @override
  String get errorAmountEmpty => 'Introduza um montante de pelo menos 1 sat.';

  @override
  String get receiveUnreachable =>
      'O Lumen não conseguiu obter uma fatura desta carteira. Verifique se está online e tente novamente.';

  @override
  String get receiveNoPermission =>
      'Esta ligação não pode criar faturas. Na sua carteira, crie uma nova ligação que permita receber pagamentos.';

  @override
  String invoiceQrLabel(String amount) {
    return 'Código QR da fatura Lightning de $amount sats. O texto da fatura está abaixo, com um botão para o copiar.';
  }

  @override
  String invoiceText(String text) {
    return 'Fatura $text';
  }

  @override
  String get editAmount => 'Editar montante';

  @override
  String get copyInvoice => 'Copiar fatura';

  @override
  String get invoiceCopied => 'Fatura copiada';

  @override
  String get shareInvoice => 'Partilhar fatura';

  @override
  String get lightningAddress => 'Endereço Lightning';

  @override
  String get copyAddress => 'Copiar endereço';

  @override
  String get addressCopied => 'Endereço copiado';

  @override
  String get showAddressQr => 'Mostrar código QR';

  @override
  String addressQrLabel(String address) {
    return 'Código QR do endereço Lightning $address';
  }

  @override
  String get shareAddress => 'Partilhar endereço';

  @override
  String get waitingForPayment => 'A aguardar pagamento';

  @override
  String get expiresSoon => 'Expira em menos de um minuto';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Expira em $minutes minutos',
      one: 'Expira em 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Expira em $hours horas',
      one: 'Expira em 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'Esta fatura expirou. Crie uma nova para receber este pagamento.';

  @override
  String get newInvoice => 'Nova fatura';

  @override
  String get paymentReceived => 'Pagamento recebido';

  @override
  String receivedInto(String name) {
    return 'Em $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Pagamento recebido: $amount sats em $name';
  }

  @override
  String get done => 'Concluir';

  @override
  String get close => 'Fechar';

  @override
  String get recentActivity => 'Atividade recente';

  @override
  String get activityLoading => 'A carregar a atividade';

  @override
  String get noActivity => 'Ainda não há pagamentos.';

  @override
  String get activityUnreachable =>
      'O Lumen não conseguiu carregar a atividade desta carteira.';

  @override
  String get activityNoPermission =>
      'Esta ligação não pode listar transações. Na sua carteira, crie uma nova ligação que permita listar transações.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'A atividade de $count carteiras não é mostrada: não foi possível carregá-la.',
      one: 'A atividade de 1 carteira não é mostrada: não foi possível carregá-la.',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get seeAllActivity => 'Ver toda a atividade';

  @override
  String get activityTitle => 'Atividade';

  @override
  String walletActivityTitle(String name) {
    return 'Atividade de $name';
  }

  @override
  String get showMore => 'Mostrar mais';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagamentos mostrados',
      one: '1 pagamento mostrado',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => 'A carregar pagamentos anteriores';

  @override
  String get activityEnd =>
      'Estes são todos os pagamentos que o Lumen guardou.';

  @override
  String get transactionReceived => 'Recebido';

  @override
  String get transactionSent => 'Enviado';

  @override
  String amountReceived(String amount) {
    return '$amount sats recebidos';
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
  String get justNow => 'Agora mesmo';

  @override
  String minutesAgo(int minutes) {
    return 'Há $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Há $hours h';
  }

  @override
  String get yesterday => 'Ontem';

  @override
  String get columnDescription => 'Descrição';

  @override
  String get columnWallet => 'Carteira';

  @override
  String get columnDate => 'Data';

  @override
  String get columnAmount => 'Montante';

  @override
  String get send => 'Enviar';

  @override
  String get sendTo => 'Para';

  @override
  String get sendToHint => 'Fatura Lightning ou endereço Lightning';

  @override
  String get paste => 'Colar';

  @override
  String get payFrom => 'Pagar a partir de';

  @override
  String get chooseWalletThatPays => 'Escolher a carteira que paga';

  @override
  String get amountSetByLink => 'Montante definido pela ligação';

  @override
  String get amountSetByInvoice => 'Montante definido pela fatura';

  @override
  String get reviewPayment => 'Rever';

  @override
  String get checkingPayment => 'A verificar';

  @override
  String get youAreSending => 'Está a enviar';

  @override
  String get detailTo => 'Para';

  @override
  String get detailNote => 'Nota';

  @override
  String get detailFrom => 'De';

  @override
  String get detailNetwork => 'Rede';

  @override
  String get detailFeePaid => 'Taxa paga';

  @override
  String get detailDate => 'Data';

  @override
  String get detailPaymentHash => 'Hash do pagamento';

  @override
  String get copyPaymentHash => 'Copiar hash do pagamento';

  @override
  String get paymentHashCopied => 'Hash do pagamento copiado';

  @override
  String get paymentTitle => 'Pagamento';

  @override
  String get paymentNotFound => 'O Lumen já não tem este pagamento.';

  @override
  String get copyPreimage => 'Copiar pré-imagem';

  @override
  String get preimageCopied => 'Pré-imagem copiada';

  @override
  String get shareReceipt => 'Partilhar recibo';

  @override
  String get receiptPreimage => 'Pré-imagem';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get liquidAddress => 'Endereço Liquid';

  @override
  String get lightningInvoice => 'Fatura Lightning';

  @override
  String sendAmount(String amount) {
    return 'Enviar $amount sats';
  }

  @override
  String get sendingPayment => 'A enviar';

  @override
  String get editPayment => 'Editar pagamento';

  @override
  String get paymentSent => 'Pagamento enviado';

  @override
  String sentTo(String label) {
    return 'Para $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Pagamento enviado: $amount sats de $name';
  }

  @override
  String get errorToEmpty =>
      'Cole uma fatura Lightning ou um endereço Lightning.';

  @override
  String get errorToUnrecognized =>
      'Isto não é uma fatura nem um endereço Lightning. Uma fatura começa por lnbc, um endereço tem o formato nome@exemplo.com.';

  @override
  String get errorInvoiceNoAmount =>
      'Esta fatura deixa o montante em aberto, o que o Lumen ainda não consegue pagar. Peça ao destinatário uma fatura com montante.';

  @override
  String get errorWrongNetwork =>
      'Este é um endereço da testnet Liquid. Peça ao destinatário um endereço da rede Liquid principal.';

  @override
  String get errorUnsupportedAsset =>
      'Este pedido é de um ativo Liquid diferente de L-BTC, que o Lumen ainda não consegue enviar. Peça ao destinatário um endereço para L-BTC.';

  @override
  String get errorNoWalletPaysAddress =>
      'Nenhuma das suas carteiras consegue pagar a um endereço Liquid. Peça antes ao destinatário uma fatura ou um endereço Lightning.';

  @override
  String get errorNoWalletPaysInvoice =>
      'Nenhuma das suas carteiras consegue pagar uma fatura ou um endereço Lightning. Peça antes ao destinatário um endereço Liquid.';

  @override
  String get errorInvoiceExpired =>
      'Esta fatura expirou. Peça uma nova ao destinatário.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label aceita de $min a $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'O Lumen não conseguiu contactar $label. Verifique o endereço e a sua ligação e tente novamente.';
  }

  @override
  String recipientRefused(String label) {
    return '$label não pode receber pagamentos neste momento. Confirme o endereço com o destinatário.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label enviou uma fatura de outro montante, por isso o Lumen não a pagou.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name tem $balance sats, o que não chega para este pagamento. Pague a partir de outra carteira ou reduza o montante.';
  }

  @override
  String sendUnreachable(String name) {
    return 'O Lumen não conseguiu contactar $name, por isso nada foi enviado. Verifique se está online e tente novamente.';
  }

  @override
  String get sendNoPermission =>
      'Esta ligação não pode pagar. Na sua carteira, crie uma nova ligação que permita pagamentos.';

  @override
  String sendInsufficientBalance(String name) {
    return '$name não tem sats suficientes para este pagamento e a respetiva taxa. Pague a partir de outra carteira ou reduza o montante.';
  }

  @override
  String get sendBudgetExceeded =>
      'Esta ligação esgotou o seu limite de gastos. Aumente-o nas definições NWC da sua carteira ou pague a partir de outra carteira.';

  @override
  String get sendFailed =>
      'O pagamento não foi concluído, muitas vezes por falta de uma rota até ao destinatário. Tente novamente mais tarde ou pague a partir de outra carteira.';

  @override
  String sendUnconfirmed(String name) {
    return '$name não confirmou o pagamento a tempo. Ainda pode ser concluído: verifique a atividade recente da carteira antes de tentar novamente.';
  }

  @override
  String get settings => 'Definições';

  @override
  String get security => 'Segurança';

  @override
  String get general => 'Geral';

  @override
  String get language => 'Idioma';

  @override
  String get deviceLanguage => 'Idioma do dispositivo';

  @override
  String get appLock => 'Bloqueio da app';

  @override
  String get appLockHint =>
      'Pede a sua frase-passe quando o Lumen abre e usa-a para cifrar as suas carteiras';

  @override
  String get changePassphrase => 'Alterar frase-passe';

  @override
  String get lockNow => 'Bloquear agora';

  @override
  String keyboardShortcut(String keys) {
    return 'Atalho de teclado: $keys';
  }

  @override
  String get turnOnAppLock => 'Ativar o bloqueio da app';

  @override
  String get passphraseLead =>
      'Escolha uma frase-passe com pelo menos 12 caracteres. Algumas palavras sem relação entre si são longas e fáceis de memorizar.';

  @override
  String get passphraseWarning =>
      'Se a esquecer, a única forma de voltar a entrar é repor o Lumen, o que remove as suas carteiras deste dispositivo. Os seus fundos ficam nos seus serviços de carteira.';

  @override
  String get passphraseLabel => 'Frase-passe';

  @override
  String get newPassphraseLabel => 'Nova frase-passe';

  @override
  String get confirmPassphraseLabel => 'Escreva-a novamente';

  @override
  String get currentPassphraseLabel => 'Frase-passe atual';

  @override
  String get showPassphrase => 'Mostrar frase-passe';

  @override
  String get hidePassphrase => 'Ocultar frase-passe';

  @override
  String get turnOn => 'Ativar';

  @override
  String get errorPassphraseShort =>
      'Use pelo menos 12 caracteres. Algumas palavras seguidas são fáceis de memorizar.';

  @override
  String get errorPassphraseMismatch =>
      'As duas frases-passe são diferentes. Escreva a mesma duas vezes.';

  @override
  String get errorPassphraseWrong =>
      'Esta não é a sua frase-passe. Verifique-a e tente novamente.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Demasiadas frases-passe erradas. Tente novamente dentro de $count segundos.',
      one: 'Demasiadas frases-passe erradas. Tente novamente dentro de 1 segundo.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Demasiadas frases-passe erradas. Tente novamente dentro de $count minutos.',
      one: 'Demasiadas frases-passe erradas. Tente novamente dentro de 1 minuto.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'O Lumen não conseguiu guardar a sua frase-passe. Tente novamente.';

  @override
  String get turnOffTitle => 'Desativar o bloqueio da app?';

  @override
  String get turnOffBody =>
      'O Lumen vai abrir sem frase-passe e as suas carteiras deixam de estar cifradas.';

  @override
  String get turnOff => 'Desativar';

  @override
  String get lockedTitle => 'O Lumen está bloqueado';

  @override
  String get lockedLead =>
      'Introduza a sua frase-passe para abrir as suas carteiras.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get forgotPassphrase => 'Esqueceu-se da frase-passe?';

  @override
  String get resetTitle => 'Repor o Lumen?';

  @override
  String get resetBody =>
      'O Lumen remove as suas carteiras e o bloqueio da app deste dispositivo. Os seus fundos ficam nos seus serviços de carteira: adicione novamente cada carteira com a respetiva cadeia de ligação.';

  @override
  String get reset => 'Repor';

  @override
  String get errorPassphraseEmpty => 'Introduza a sua frase-passe.';

  @override
  String get scan => 'Digitalizar';

  @override
  String get scanQrCode => 'Digitalizar um código QR';

  @override
  String get scanHint => 'Aponte a câmara para um código QR.';

  @override
  String get turnOnLight => 'Ligar a lanterna';

  @override
  String get turnOffLight => 'Desligar a lanterna';

  @override
  String get cameraNeeded =>
      'Permita que o Lumen use a câmara para digitalizar códigos QR. Também pode fechar este ecrã e colar o texto.';

  @override
  String get allowCamera => 'Permitir câmara';

  @override
  String get openSettings => 'Abrir definições';

  @override
  String get noCamera =>
      'Nenhuma câmara disponível. Feche este ecrã e cole o texto.';

  @override
  String get addWalletLead =>
      'Crie uma carteira nova ou restaure uma que já tenha.';

  @override
  String get addLightningTitle => 'Carteira Lightning';

  @override
  String get addLightningBody =>
      'Ligue um nó ou um serviço de carteira com Nostr Wallet Connect (NIP-47).';

  @override
  String get addLiquidBody =>
      'Transferências rápidas e confidenciais na sidechain Liquid. O Lumen guarda as chaves.';

  @override
  String get liquidStartTitle => 'Carteira Liquid';

  @override
  String get liquidStartLead =>
      'O Lumen cria a carteira e guarda as chaves neste dispositivo. Uma frase de recuperação de 12 palavras permite recuperá-la.';

  @override
  String get liquidPointFast => 'Os pagamentos confirmam em cerca de um minuto';

  @override
  String get liquidPointConfidential =>
      'Os montantes ficam ocultos para quem observa a cadeia';

  @override
  String get liquidPointKeys => 'As suas chaves ficam no seu dispositivo';

  @override
  String get createLiquidWallet => 'Criar uma carteira nova';

  @override
  String get newLiquidTitle => 'Nova carteira Liquid';

  @override
  String get phraseIntroHeading => 'Primeiro, a sua frase de recuperação';

  @override
  String get phraseIntroBody =>
      'O Lumen vai mostrar 12 palavras. São a única forma de recuperar esta carteira se perder ou repuser este dispositivo, e quem as tiver pode gastar os fundos.';

  @override
  String get phrasePointPaper => 'Escreva-as em papel, por ordem';

  @override
  String get phrasePointOffline =>
      'Guarde-as offline: sem capturas de ecrã, fotos ou notas na nuvem';

  @override
  String get phrasePointNeverAsked =>
      'O Lumen só as pede para restaurar uma carteira';

  @override
  String get showPhrase => 'Mostrar as 12 palavras';

  @override
  String get liquidUnavailable =>
      'O Lumen não conseguiu iniciar o Liquid neste dispositivo. Tente mais tarde.';

  @override
  String get phraseTitle => 'Frase de recuperação';

  @override
  String get phraseLead =>
      'Escreva estas 12 palavras em papel, por esta ordem. A seguir vai escrever três delas.';

  @override
  String phraseWord(int number, int total, String word) {
    return 'Palavra $number de $total, $word';
  }

  @override
  String get phraseWrittenDown => 'Já as escrevi';

  @override
  String get checkPhraseTitle => 'Confirme a frase';

  @override
  String get checkPhraseLead =>
      'Escreva estas palavras a partir do seu papel, para confirmar que estão certas.';

  @override
  String wordLabel(int number, int total) {
    return 'Palavra $number de $total';
  }

  @override
  String errorWordEmpty(int number) {
    return 'Escreva a palavra $number do seu papel.';
  }

  @override
  String errorWordMismatch(int number) {
    return 'Esta não é a palavra $number. Verifique o papel e escreva-a de novo.';
  }

  @override
  String wordSuggestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugestões',
      one: '1 sugestão',
    );
    return '$_temp0';
  }

  @override
  String get showWordsAgain => 'Ver as palavras outra vez';

  @override
  String get testnet => 'Testnet';

  @override
  String get testnetHint =>
      'Apenas para testes. As moedas da testnet não têm valor.';

  @override
  String get createWallet => 'Criar carteira';

  @override
  String get errorSaveWallet =>
      'O Lumen não conseguiu guardar a carteira. Tente de novo.';

  @override
  String get restoreLiquidWallet => 'Restaurar uma carteira';

  @override
  String get restoreLiquidTitle => 'Restaurar uma carteira Liquid';

  @override
  String get restoreLead =>
      'Escreva as palavras da sua frase de recuperação, por ordem. Também pode colar a frase inteira no primeiro campo.';

  @override
  String get errorWordUnknown =>
      'Esta palavra não faz parte da lista das frases de recuperação. Verifique a ortografia.';

  @override
  String get errorPhraseChecksum =>
      'Estas palavras não formam uma frase de recuperação. Uma delas pode estar errada ou fora do lugar: compare cada uma com o seu papel.';

  @override
  String get restoreScanning =>
      'A procurar os pagamentos desta carteira. Pode demorar um minuto.';

  @override
  String get restoreWallet => 'Restaurar carteira';

  @override
  String get errorRestoreUnreachable =>
      'O Lumen não conseguiu contactar o servidor Liquid para procurar os pagamentos desta carteira. Verifique a ligação e tente de novo.';

  @override
  String get errorRestoreDuplicate => 'Esta carteira já está no Lumen.';

  @override
  String wordsPasted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras preenchidas',
      one: '1 palavra preenchida',
    );
    return '$_temp0';
  }

  @override
  String get phraseLength => 'Tamanho da frase';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras',
      one: '1 palavra',
    );
    return '$_temp0';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get tagline =>
      'Todas as formas de guardar seus bitcoins, em um só lugar.';

  @override
  String get supportedWallets => 'Carteiras compatíveis';

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
  String get addAWallet => 'Adicionar uma carteira';

  @override
  String get add => 'Adicionar';

  @override
  String get addWallet => 'Adicionar carteira';

  @override
  String get back => 'Voltar';

  @override
  String get connectNwcTitle => 'Conectar com NWC';

  @override
  String get connectNwcLead =>
      'Copie a string de conexão nas configurações NWC da sua carteira.';

  @override
  String get connectionStringLabel => 'String de conexão';

  @override
  String get connectionStringHint => 'Começa com nostr+walletconnect://';

  @override
  String get nameLabel => 'Nome';

  @override
  String get connect => 'Conectar';

  @override
  String get errorUriEmpty =>
      'Cole a string de conexão das configurações NWC da sua carteira.';

  @override
  String get errorUriNotNwc =>
      'Isto não é uma string de conexão NWC. Ela deve começar com nostr+walletconnect://';

  @override
  String get errorUriIncomplete =>
      'Esta string de conexão está incompleta. Copie-a de novo da sua carteira, por inteiro.';

  @override
  String get errorUriDuplicate => 'Esta carteira já está no Lumen.';

  @override
  String get grantChecking => 'Verificando o que esta conexão permite';

  @override
  String get grantUnreachable =>
      'O Lumen não conseguiu acessar esta carteira para verificar o que a conexão permite. Você ainda pode conectá-la.';

  @override
  String get grantCan => 'Esta conexão pode';

  @override
  String get grantCannot => 'Esta conexão não pode';

  @override
  String get grantAllowed => 'Permitido';

  @override
  String get grantDenied => 'Não permitido';

  @override
  String get abilityReadBalance => 'Ver o saldo';

  @override
  String get abilityReceive => 'Criar faturas';

  @override
  String get abilityPay => 'Pagar faturas';

  @override
  String get abilityListTransactions => 'Listar transações';

  @override
  String budgetPerDay(String amount) {
    return 'Até $amount sats por dia';
  }

  @override
  String budgetPerWeek(String amount) {
    return 'Até $amount sats por semana';
  }

  @override
  String budgetPerMonth(String amount) {
    return 'Até $amount sats por mês';
  }

  @override
  String budgetPerYear(String amount) {
    return 'Até $amount sats por ano';
  }

  @override
  String budgetTotal(String amount) {
    return 'Até $amount sats no total';
  }

  @override
  String get balanceNoPermission =>
      'Esta conexão não pode ler o saldo. Na sua carteira, crie uma nova conexão que permita ler o saldo.';

  @override
  String get errorNameEmpty => 'Dê um nome a esta carteira.';

  @override
  String get overview => 'Visão geral';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get wallets => 'Carteiras';

  @override
  String get satsUnit => 'sats';

  @override
  String amountSats(String amount) {
    return '$amount sats';
  }

  @override
  String get balanceLoading => 'Carregando saldo';

  @override
  String get balanceUnavailable => 'Indisponível';

  @override
  String walletsNotCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count carteiras não foram incluídas: os saldos delas estão indisponíveis.',
      one: '1 carteira não foi incluída: o saldo dela está indisponível.',
    );
    return '$_temp0';
  }

  @override
  String get walletUnreachable =>
      'O Lumen não conseguiu acessar esta carteira.';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get copyConnection => 'Copiar string de conexão';

  @override
  String get copyConnectionTitle => 'Copiar a string de conexão?';

  @override
  String get copyConnectionBody =>
      'Quem tiver essa string pode usar esta carteira como o Lumen, inclusive pagar se a conexão permitir. Cole-a apenas em um app de confiança.';

  @override
  String get copy => 'Copiar';

  @override
  String get connectionCopied => 'String de conexão copiada.';

  @override
  String walletOptions(String name) {
    return 'Opções de $name';
  }

  @override
  String get rename => 'Renomear';

  @override
  String get remove => 'Remover';

  @override
  String get renameTitle => 'Renomear carteira';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String removeTitle(String name) {
    return 'Remover $name?';
  }

  @override
  String get removeBody =>
      'O Lumen esquece esta conexão. A carteira e os fundos dela não são afetados, e você pode conectá-la de novo depois.';

  @override
  String get refreshBalances => 'Atualizar saldos';

  @override
  String get refreshBalance => 'Atualizar saldo';

  @override
  String get receive => 'Receber';

  @override
  String get receiveInto => 'Em';

  @override
  String get chooseWallet => 'Escolha a carteira que recebe';

  @override
  String get amountLabel => 'Valor em sats';

  @override
  String get createInvoice => 'Criar fatura';

  @override
  String get creatingInvoice => 'Criando fatura';

  @override
  String get errorAmountEmpty => 'Digite um valor de pelo menos 1 sat.';

  @override
  String get receiveUnreachable =>
      'O Lumen não conseguiu obter uma fatura desta carteira. Verifique se ela está online e tente novamente.';

  @override
  String get receiveNoPermission =>
      'Esta conexão não pode criar faturas. Na sua carteira, crie uma nova conexão que permita receber pagamentos.';

  @override
  String invoiceQrLabel(String amount) {
    return 'QR code da fatura Lightning de $amount sats. O texto da fatura está abaixo, com um botão para copiar.';
  }

  @override
  String invoiceText(String text) {
    return 'Fatura $text';
  }

  @override
  String get editAmount => 'Editar valor';

  @override
  String get copyInvoice => 'Copiar fatura';

  @override
  String get invoiceCopied => 'Fatura copiada';

  @override
  String get shareInvoice => 'Compartilhar fatura';

  @override
  String get lightningAddress => 'Endereço Lightning';

  @override
  String get copyAddress => 'Copiar endereço';

  @override
  String get addressCopied => 'Endereço copiado';

  @override
  String get showAddressQr => 'Mostrar QR code';

  @override
  String addressQrLabel(String address) {
    return 'QR code do endereço Lightning $address';
  }

  @override
  String get shareAddress => 'Compartilhar endereço';

  @override
  String get waitingForPayment => 'Aguardando pagamento';

  @override
  String get expiresSoon => 'Expira em menos de um minuto';

  @override
  String expiresInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Expira em $minutes minutos',
      one: 'Expira em 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String expiresInHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Expira em $hours horas',
      one: 'Expira em 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get invoiceExpired =>
      'Esta fatura expirou. Crie uma nova para receber este pagamento.';

  @override
  String get newInvoice => 'Nova fatura';

  @override
  String get paymentReceived => 'Pagamento recebido';

  @override
  String receivedInto(String name) {
    return 'Em $name';
  }

  @override
  String receivedAnnouncement(String amount, String name) {
    return 'Pagamento recebido: $amount sats em $name';
  }

  @override
  String get done => 'Concluído';

  @override
  String get close => 'Fechar';

  @override
  String get recentActivity => 'Atividade recente';

  @override
  String get activityLoading => 'Carregando atividade';

  @override
  String get noActivity => 'Nenhum pagamento ainda.';

  @override
  String get activityUnreachable =>
      'O Lumen não conseguiu carregar a atividade desta carteira.';

  @override
  String get activityNoPermission =>
      'Esta conexão não pode listar transações. Na sua carteira, crie uma nova conexão que permita listar transações.';

  @override
  String activityNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'A atividade de $count carteiras não é exibida: não foi possível carregá-la.',
      one: 'A atividade de 1 carteira não é exibida: não foi possível carregá-la.',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get seeAllActivity => 'Ver toda a atividade';

  @override
  String get activityTitle => 'Atividade';

  @override
  String walletActivityTitle(String name) {
    return 'Atividade de $name';
  }

  @override
  String get showMore => 'Mostrar mais';

  @override
  String activityShownCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagamentos exibidos',
      one: '1 pagamento exibido',
    );
    return '$_temp0';
  }

  @override
  String get loadingOlder => 'Carregando pagamentos anteriores';

  @override
  String get activityEnd => 'Estes são todos os pagamentos que o Lumen salvou.';

  @override
  String get transactionReceived => 'Recebido';

  @override
  String get transactionSent => 'Enviado';

  @override
  String amountReceived(String amount) {
    return '$amount sats recebidos';
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
  String get justNow => 'Agora mesmo';

  @override
  String minutesAgo(int minutes) {
    return 'Há $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Há $hours h';
  }

  @override
  String get yesterday => 'Ontem';

  @override
  String get columnDescription => 'Descrição';

  @override
  String get columnWallet => 'Carteira';

  @override
  String get columnDate => 'Data';

  @override
  String get columnAmount => 'Valor';

  @override
  String get send => 'Enviar';

  @override
  String get sendTo => 'Para';

  @override
  String get sendToHint => 'Fatura Lightning ou endereço Lightning';

  @override
  String get paste => 'Colar';

  @override
  String get payFrom => 'Pagar com';

  @override
  String get chooseWalletThatPays => 'Escolha a carteira que paga';

  @override
  String get amountSetByLink => 'Valor definido pelo link';

  @override
  String get amountSetByInvoice => 'Valor definido pela fatura';

  @override
  String get reviewPayment => 'Revisar';

  @override
  String get checkingPayment => 'Verificando';

  @override
  String get youAreSending => 'Você está enviando';

  @override
  String get detailTo => 'Para';

  @override
  String get detailNote => 'Nota';

  @override
  String get detailFrom => 'De';

  @override
  String get detailNetwork => 'Rede';

  @override
  String get detailFeePaid => 'Taxa paga';

  @override
  String get detailDate => 'Data';

  @override
  String get detailPaymentHash => 'Hash do pagamento';

  @override
  String get copyPaymentHash => 'Copiar hash do pagamento';

  @override
  String get paymentHashCopied => 'Hash do pagamento copiado';

  @override
  String get paymentTitle => 'Pagamento';

  @override
  String get paymentNotFound => 'O Lumen não tem mais este pagamento.';

  @override
  String get copyPreimage => 'Copiar pré-imagem';

  @override
  String get preimageCopied => 'Pré-imagem copiada';

  @override
  String get shareReceipt => 'Compartilhar recibo';

  @override
  String get receiptPreimage => 'Pré-imagem';

  @override
  String receiptLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get liquidAddress => 'Endereço Liquid';

  @override
  String get lightningInvoice => 'Fatura Lightning';

  @override
  String sendAmount(String amount) {
    return 'Enviar $amount sats';
  }

  @override
  String get sendingPayment => 'Enviando';

  @override
  String get editPayment => 'Editar pagamento';

  @override
  String get paymentSent => 'Pagamento enviado';

  @override
  String sentTo(String label) {
    return 'Para $label';
  }

  @override
  String sentAnnouncement(String amount, String name) {
    return 'Pagamento enviado: $amount sats de $name';
  }

  @override
  String get errorToEmpty =>
      'Cole uma fatura Lightning ou um endereço Lightning.';

  @override
  String get errorToUnrecognized =>
      'Isto não é uma fatura nem um endereço Lightning. Uma fatura começa com lnbc, um endereço é parecido com nome@exemplo.com.';

  @override
  String get errorInvoiceNoAmount =>
      'Esta fatura deixa o valor em aberto, e o Lumen ainda não consegue pagá-la. Peça ao destinatário uma fatura com valor.';

  @override
  String get errorWrongNetwork =>
      'Este é um endereço da testnet Liquid. Peça ao destinatário um endereço da rede Liquid principal.';

  @override
  String get errorUnsupportedAsset =>
      'Esta solicitação é de um ativo Liquid diferente de L-BTC, que o Lumen ainda não consegue enviar. Peça ao destinatário um endereço para L-BTC.';

  @override
  String get errorNoWalletPaysAddress =>
      'Nenhuma das suas carteiras consegue pagar um endereço Liquid. Peça ao destinatário uma fatura ou um endereço Lightning.';

  @override
  String get errorNoWalletPaysInvoice =>
      'Nenhuma das suas carteiras consegue pagar uma fatura ou um endereço Lightning. Peça ao destinatário um endereço Liquid.';

  @override
  String get errorInvoiceExpired =>
      'Esta fatura expirou. Peça uma nova ao destinatário.';

  @override
  String errorAmountRange(String label, String min, String max) {
    return '$label aceita de $min a $max sats.';
  }

  @override
  String recipientUnreachable(String label) {
    return 'O Lumen não conseguiu acessar $label. Verifique o endereço e a sua conexão e tente novamente.';
  }

  @override
  String recipientRefused(String label) {
    return '$label não pode receber pagamentos agora. Confira o endereço com o destinatário.';
  }

  @override
  String recipientWrongInvoice(String label) {
    return '$label enviou uma fatura de outro valor, então o Lumen não a pagou.';
  }

  @override
  String notEnoughSats(String name, String balance) {
    return '$name tem $balance sats, o que não basta para este pagamento. Pague com outra carteira ou diminua o valor.';
  }

  @override
  String sendUnreachable(String name) {
    return 'O Lumen não conseguiu acessar $name, então nada foi enviado. Verifique se ela está online e tente novamente.';
  }

  @override
  String get sendNoPermission =>
      'Esta conexão não pode pagar. Na sua carteira, crie uma nova conexão que permita pagamentos.';

  @override
  String sendInsufficientBalance(String name) {
    return '$name não tem sats suficientes para este pagamento e a taxa. Pague com outra carteira ou diminua o valor.';
  }

  @override
  String get sendBudgetExceeded =>
      'Esta conexão esgotou o limite de gastos. Aumente-o nas configurações NWC da sua carteira ou pague com outra carteira.';

  @override
  String get sendFailed =>
      'O pagamento não foi concluído, muitas vezes por falta de rota até o destinatário. Tente novamente mais tarde ou pague com outra carteira.';

  @override
  String sendUnconfirmed(String name) {
    return '$name não confirmou o pagamento a tempo. Ele ainda pode ser concluído: confira a atividade recente dela antes de tentar novamente.';
  }

  @override
  String get settings => 'Configurações';

  @override
  String get security => 'Segurança';

  @override
  String get general => 'Geral';

  @override
  String get language => 'Idioma';

  @override
  String get deviceLanguage => 'Idioma do dispositivo';

  @override
  String get appLock => 'Bloqueio do app';

  @override
  String get appLockHint =>
      'Pede sua frase-senha quando o Lumen abre e criptografa suas carteiras com ela';

  @override
  String get changePassphrase => 'Alterar frase-senha';

  @override
  String get lockNow => 'Bloquear agora';

  @override
  String keyboardShortcut(String keys) {
    return 'Atalho de teclado: $keys';
  }

  @override
  String get turnOnAppLock => 'Ativar bloqueio do app';

  @override
  String get passphraseLead =>
      'Escolha uma frase-senha de pelo menos 12 caracteres. Algumas palavras sem relação entre si são longas e fáceis de lembrar.';

  @override
  String get passphraseWarning =>
      'Se você esquecê-la, a única forma de voltar a entrar é redefinir o Lumen, o que remove suas carteiras deste dispositivo. Seus fundos continuam nos serviços das suas carteiras.';

  @override
  String get passphraseLabel => 'Frase-senha';

  @override
  String get newPassphraseLabel => 'Nova frase-senha';

  @override
  String get confirmPassphraseLabel => 'Digite de novo';

  @override
  String get currentPassphraseLabel => 'Frase-senha atual';

  @override
  String get showPassphrase => 'Mostrar frase-senha';

  @override
  String get hidePassphrase => 'Ocultar frase-senha';

  @override
  String get turnOn => 'Ativar';

  @override
  String get errorPassphraseShort =>
      'Use pelo menos 12 caracteres. Algumas palavras em sequência são fáceis de lembrar.';

  @override
  String get errorPassphraseMismatch =>
      'As duas frases-senha são diferentes. Digite a mesma duas vezes.';

  @override
  String get errorPassphraseWrong =>
      'Esta não é a sua frase-senha. Confira e tente novamente.';

  @override
  String errorWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Muitas frases-senha erradas. Tente novamente em $count segundos.',
      one: 'Muitas frases-senha erradas. Tente novamente em 1 segundo.',
    );
    return '$_temp0';
  }

  @override
  String errorWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Muitas frases-senha erradas. Tente novamente em $count minutos.',
      one: 'Muitas frases-senha erradas. Tente novamente em 1 minuto.',
    );
    return '$_temp0';
  }

  @override
  String get errorLockSave =>
      'O Lumen não conseguiu salvar sua frase-senha. Tente novamente.';

  @override
  String get turnOffTitle => 'Desativar bloqueio do app?';

  @override
  String get turnOffBody =>
      'O Lumen vai abrir sem frase-senha, e suas carteiras não serão mais criptografadas.';

  @override
  String get turnOff => 'Desativar';

  @override
  String get lockedTitle => 'O Lumen está bloqueado';

  @override
  String get lockedLead => 'Digite sua frase-senha para abrir suas carteiras.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get forgotPassphrase => 'Esqueceu sua frase-senha?';

  @override
  String get resetTitle => 'Redefinir o Lumen?';

  @override
  String get resetBody =>
      'O Lumen remove suas carteiras e o bloqueio do app deste dispositivo. Seus fundos continuam nos serviços das suas carteiras: adicione cada carteira de novo com a string de conexão dela.';

  @override
  String get reset => 'Redefinir';

  @override
  String get errorPassphraseEmpty => 'Digite sua frase-senha.';

  @override
  String get scan => 'Escanear';

  @override
  String get scanQrCode => 'Escanear um QR code';

  @override
  String get scanHint => 'Aponte a câmera para um QR code.';

  @override
  String get turnOnLight => 'Ligar a lanterna';

  @override
  String get turnOffLight => 'Desligar a lanterna';

  @override
  String get cameraNeeded =>
      'Permita que o Lumen use a câmera para escanear QR codes. Você também pode fechar esta tela e colar o texto.';

  @override
  String get allowCamera => 'Permitir câmera';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get noCamera =>
      'Nenhuma câmera disponível. Feche esta tela e cole o texto.';

  @override
  String get addWalletLead =>
      'Crie uma carteira nova ou restaure uma que você já tem.';

  @override
  String get addLightningTitle => 'Carteira Lightning';

  @override
  String get addLightningBody =>
      'Conecte um nó ou um serviço de carteira com Nostr Wallet Connect (NIP-47).';

  @override
  String get addLiquidBody =>
      'Transferências rápidas e confidenciais na sidechain Liquid. O Lumen guarda as chaves.';

  @override
  String get liquidStartTitle => 'Carteira Liquid';

  @override
  String get liquidStartLead =>
      'O Lumen cria a carteira e guarda as chaves neste dispositivo. Uma frase de recuperação de 12 palavras permite recuperá-la.';

  @override
  String get liquidPointFast => 'Os pagamentos confirmam em cerca de um minuto';

  @override
  String get liquidPointConfidential =>
      'Os valores ficam ocultos para quem observa a rede';

  @override
  String get liquidPointKeys => 'Suas chaves ficam no seu dispositivo';

  @override
  String get createLiquidWallet => 'Criar uma carteira nova';

  @override
  String get newLiquidTitle => 'Nova carteira Liquid';

  @override
  String get phraseIntroHeading => 'Primeiro, sua frase de recuperação';

  @override
  String get phraseIntroBody =>
      'O Lumen vai mostrar 12 palavras. Elas são o único jeito de recuperar esta carteira se você perder ou redefinir este dispositivo, e quem tiver as palavras pode gastar os fundos.';

  @override
  String get phrasePointPaper => 'Anote-as no papel, em ordem';

  @override
  String get phrasePointOffline =>
      'Guarde-as offline: sem captura de tela, foto ou nota na nuvem';

  @override
  String get phrasePointNeverAsked =>
      'O Lumen só pede as palavras para restaurar uma carteira';

  @override
  String get showPhrase => 'Mostrar as 12 palavras';

  @override
  String get liquidUnavailable =>
      'O Lumen não conseguiu iniciar o Liquid neste dispositivo. Tente mais tarde.';

  @override
  String get phraseTitle => 'Frase de recuperação';

  @override
  String get phraseLead =>
      'Anote estas 12 palavras no papel, nesta ordem. Em seguida, você vai digitar três delas.';

  @override
  String phraseWord(int number, int total, String word) {
    return 'Palavra $number de $total, $word';
  }

  @override
  String get phraseWrittenDown => 'Já anotei';

  @override
  String get checkPhraseTitle => 'Confira sua frase';

  @override
  String get checkPhraseLead =>
      'Digite estas palavras a partir do seu papel, para conferir se estão certas.';

  @override
  String wordLabel(int number, int total) {
    return 'Palavra $number de $total';
  }

  @override
  String errorWordEmpty(int number) {
    return 'Digite a palavra $number do seu papel.';
  }

  @override
  String errorWordMismatch(int number) {
    return 'Esta não é a palavra $number. Confira o papel e digite de novo.';
  }

  @override
  String wordSuggestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugestões',
      one: '1 sugestão',
    );
    return '$_temp0';
  }

  @override
  String get showWordsAgain => 'Ver as palavras de novo';

  @override
  String get testnet => 'Testnet';

  @override
  String get testnetHint =>
      'Apenas para testes. As moedas da testnet não têm valor.';

  @override
  String get createWallet => 'Criar carteira';

  @override
  String get errorSaveWallet =>
      'O Lumen não conseguiu salvar a carteira. Tente de novo.';

  @override
  String get restoreLiquidWallet => 'Restaurar uma carteira';

  @override
  String get restoreLiquidTitle => 'Restaurar uma carteira Liquid';

  @override
  String get restoreLead =>
      'Digite as palavras da sua frase de recuperação, em ordem. Você também pode colar a frase inteira no primeiro campo.';

  @override
  String get errorWordUnknown =>
      'Esta palavra não está na lista das frases de recuperação. Confira a ortografia.';

  @override
  String get errorPhraseChecksum =>
      'Estas palavras não formam uma frase de recuperação. Uma delas pode estar errada ou fora do lugar: confira cada uma com o seu papel.';

  @override
  String get restoreScanning =>
      'Procurando os pagamentos desta carteira. Isso pode levar um minuto.';

  @override
  String get restoreWallet => 'Restaurar carteira';

  @override
  String get errorRestoreUnreachable =>
      'O Lumen não conseguiu acessar o servidor Liquid para procurar os pagamentos desta carteira. Confira sua conexão e tente de novo.';

  @override
  String get errorRestoreDuplicate => 'Esta carteira já está no Lumen.';

  @override
  String wordsPasted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras preenchidas',
      one: '1 palavra preenchida',
    );
    return '$_temp0';
  }

  @override
  String get phraseLength => 'Tamanho da frase';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras',
      one: '1 palavra',
    );
    return '$_temp0';
  }
}
