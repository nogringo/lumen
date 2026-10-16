use std::str::FromStr;
use std::sync::Arc;

use flutter_rust_bridge::frb;
use lwk_common::{singlesig_desc, DescriptorBlindingKey, Signer, Singlesig};
use lwk_signer::bip39::{Error as Bip39Error, Language, Mnemonic};
use lwk_signer::SwSigner;
use lwk_wollet::asyncr::{EsploraClient, EsploraClientBuilder};
use lwk_wollet::elements::pset::PartiallySignedTransaction;
use lwk_wollet::elements::{Address, Transaction};
use lwk_wollet::{
    Chain, MemoryStore, Network, Update, Wollet, WolletBuilder, WolletDescriptor,
};
use tokio::sync::Mutex;

pub enum LiquidNetwork {
    Mainnet,
    Testnet,
}

/// How addresses are derived from the phrase. Lumen creates native segwit
/// wallets; other apps may have made nested ones from the same phrase.
pub enum ScriptKind {
    /// BIP84, `elwpkh`.
    NativeSegwit,

    /// BIP49, `elsh(wpkh)`.
    NestedSegwit,
}

#[derive(Debug, PartialEq)]
pub enum LiquidErrorKind {
    /// The chain server did not answer, or answered an error it may not give
    /// next time. Nothing was sent.
    Unreachable,
    /// The chain server refused the transaction.
    Rejected,
    InsufficientFunds,
    InvalidAddress,
    WrongNetwork,
    Other,
}

#[derive(Debug)]
pub struct LiquidError {
    pub kind: LiquidErrorKind,
    pub message: String,
}

impl From<lwk_wollet::Error> for LiquidError {
    fn from(error: lwk_wollet::Error) -> Self {
        use lwk_wollet::Error as E;
        let kind = match &error {
            E::Reqwest(_) | E::RateLimited => LiquidErrorKind::Unreachable,
            E::EsploraHttpError { status, .. } if *status == 429 || *status >= 500 => {
                LiquidErrorKind::Unreachable
            }
            E::EsploraHttpError { .. } => LiquidErrorKind::Rejected,
            E::InsufficientFunds { .. } => LiquidErrorKind::InsufficientFunds,
            E::InvalidNetwork => LiquidErrorKind::WrongNetwork,
            E::AddressError(_) | E::NotConfidentialAddress => LiquidErrorKind::InvalidAddress,
            _ => LiquidErrorKind::Other,
        };
        LiquidError {
            kind,
            message: error.to_string(),
        }
    }
}

fn other(error: impl std::fmt::Debug) -> LiquidError {
    LiquidError {
        kind: LiquidErrorKind::Other,
        message: format!("{error:?}"),
    }
}

pub enum PhraseProblem {
    WordCount,
    UnknownWord,
    Checksum,
}

/// A new 12-word recovery phrase.
#[frb(sync)]
pub fn generate_phrase() -> Result<String, LiquidError> {
    let (_, mnemonic) = SwSigner::random(true).map_err(other)?;
    Ok(mnemonic.to_string())
}

/// What is wrong with [phrase], or None when it is a valid 12-word phrase.
#[frb(sync)]
pub fn phrase_problem(phrase: String) -> Option<PhraseProblem> {
    if phrase.split_whitespace().count() != 12 {
        return Some(PhraseProblem::WordCount);
    }
    match Mnemonic::parse_in_normalized(Language::English, &phrase) {
        Ok(_) => None,
        Err(Bip39Error::UnknownWord(_)) => Some(PhraseProblem::UnknownWord),
        Err(Bip39Error::InvalidChecksum) => Some(PhraseProblem::Checksum),
        Err(_) => Some(PhraseProblem::WordCount),
    }
}

/// The CT descriptor [phrase] gives on [network].
#[frb(sync)]
pub fn descriptor(
    phrase: String,
    network: LiquidNetwork,
    script: ScriptKind,
) -> Result<String, LiquidError> {
    let signer = signer(&phrase, &network)?;
    Ok(descriptor_of(&signer, &script)?.to_string())
}

fn signer(phrase: &str, network: &LiquidNetwork) -> Result<SwSigner, LiquidError> {
    SwSigner::new(phrase, matches!(network, LiquidNetwork::Mainnet)).map_err(other)
}

fn descriptor_of(signer: &SwSigner, script: &ScriptKind) -> Result<WolletDescriptor, LiquidError> {
    let variant = match script {
        ScriptKind::NativeSegwit => Singlesig::Wpkh,
        ScriptKind::NestedSegwit => Singlesig::ShWpkh,
    };
    singlesig_desc(signer, variant, DescriptorBlindingKey::Slip77)
        .map_err(other)?
        .parse()
        .map_err(other)
}

pub struct LiquidAddress {
    pub address: String,
    pub index: u32,
}

pub struct LiquidTx {
    pub txid: String,
    /// The wallet's net L-BTC change, fee included.
    pub balance: i64,
    pub fee: u64,
    /// The block that confirms it, None while in the mempool.
    pub height: Option<u32>,
    /// The block time, in seconds.
    pub timestamp: Option<u32>,
    /// The wallet's receiving addresses this transaction pays.
    pub received: Vec<String>,
}

/// A payment built and checked, ready to sign.
#[frb(opaque)]
pub struct LiquidDraft {
    pset: PartiallySignedTransaction,
    fee: u64,
}

impl LiquidDraft {
    #[frb(sync, getter)]
    pub fn fee(&self) -> u64 {
        self.fee
    }
}

#[frb(opaque)]
pub struct LiquidSigned {
    tx: Transaction,
}

impl LiquidSigned {
    #[frb(sync, getter)]
    pub fn txid(&self) -> String {
        self.tx.txid().to_string()
    }
}

#[frb(opaque)]
pub struct LiquidWallet {
    network: Network,
    signer: SwSigner,
    descriptor: WolletDescriptor,
    wollet: Mutex<Wollet>,
    client: Mutex<EsploraClient>,
}

impl LiquidWallet {
    /// [state] is what [LiquidWallet::state] returned last time, so the next
    /// sync only fetches what changed.
    pub async fn open(
        phrase: String,
        network: LiquidNetwork,
        script: ScriptKind,
        esplora_url: String,
        state: Vec<String>,
    ) -> Result<LiquidWallet, LiquidError> {
        let signer = signer(&phrase, &network)?;
        let descriptor = descriptor_of(&signer, &script)?;
        let network = match network {
            LiquidNetwork::Mainnet => Network::Liquid,
            LiquidNetwork::Testnet => Network::TestnetLiquid,
        };
        let mut wollet = WolletBuilder::new(network.clone(), descriptor.clone())
            .with_stores(Arc::new(MemoryStore::new()))?
            .build()?;
        for saved in state {
            let update = Update::deserialize_decrypted_base64(&saved, &descriptor)?;
            wollet.apply_update(update)?;
        }
        // More than 4 requests at a time gets rate limited.
        let client = EsploraClientBuilder::new(&esplora_url, network.clone())
            .concurrency(4)
            .build()?;
        Ok(LiquidWallet {
            network,
            signer,
            descriptor,
            wollet: Mutex::new(wollet),
            client: Mutex::new(client),
        })
    }

    #[frb(sync)]
    pub fn descriptor(&self) -> String {
        self.descriptor.to_string()
    }

    /// Returns whether anything changed.
    pub async fn sync(&self) -> Result<bool, LiquidError> {
        let mut client = self.client.lock().await;
        let mut wollet = self.wollet.lock().await;
        match client.full_scan(&wollet).await? {
            Some(update) => {
                wollet.apply_update(update)?;
                Ok(true)
            }
            None => Ok(false),
        }
    }

    /// The chain state, encrypted with a key derived from the descriptor.
    pub async fn state(&self) -> Result<Vec<String>, LiquidError> {
        let wollet = self.wollet.lock().await;
        Ok(wollet
            .updates()?
            .iter()
            .map(|update| update.serialize_encrypted_base64(&self.descriptor))
            .collect::<Result<_, _>>()?)
    }

    /// L-BTC, in sats.
    pub async fn balance(&self) -> Result<u64, LiquidError> {
        let wollet = self.wollet.lock().await;
        let policy = wollet.policy_asset();
        Ok(wollet.balance()?.get(&policy).copied().unwrap_or(0))
    }

    pub async fn tip_height(&self) -> u32 {
        self.wollet.lock().await.tip().height()
    }

    /// The receiving address at [index], or the first one not paid yet.
    pub async fn address(&self, index: Option<u32>) -> Result<LiquidAddress, LiquidError> {
        let wollet = self.wollet.lock().await;
        let result = wollet.address(index)?;
        Ok(LiquidAddress {
            address: result.address().to_string(),
            index: result.index(),
        })
    }

    /// Newest first.
    pub async fn transactions(&self) -> Result<Vec<LiquidTx>, LiquidError> {
        let wollet = self.wollet.lock().await;
        let policy = wollet.policy_asset();
        let mut list = vec![];
        for tx in wollet.transactions()? {
            let mut received = vec![];
            for output in tx.outputs.iter().flatten() {
                if output.ext_int == Chain::External {
                    let address = wollet.address(Some(output.wildcard_index))?;
                    received.push(address.address().to_string());
                }
            }
            list.push(LiquidTx {
                txid: tx.txid.to_string(),
                balance: tx.balance.get(&policy).copied().unwrap_or(0),
                fee: tx.fee,
                height: tx.height,
                timestamp: tx.timestamp,
                received,
            });
        }
        Ok(list)
    }

    /// Builds a payment of [sats] L-BTC to [address] and quotes its fee,
    /// without signing or sending it.
    pub async fn prepare_send(
        &self,
        address: String,
        sats: u64,
    ) -> Result<LiquidDraft, LiquidError> {
        let address = Address::from_str(&address).map_err(|e| LiquidError {
            kind: LiquidErrorKind::InvalidAddress,
            message: e.to_string(),
        })?;
        if address.params != self.network.address_params() {
            return Err(LiquidError {
                kind: LiquidErrorKind::WrongNetwork,
                message: "address from another network".into(),
            });
        }
        let wollet = self.wollet.lock().await;
        let builder = wollet.tx_builder();
        let builder = if address.is_blinded() {
            builder.add_lbtc_recipient(&address, sats)?
        } else {
            builder.add_explicit_recipient(&address, sats, wollet.policy_asset())?
        };
        let pset = builder.finish()?;
        let fee = wollet
            .get_details(&pset)?
            .balance()
            .fees()
            .get(&wollet.policy_asset())
            .copied()
            .unwrap_or(0);
        Ok(LiquidDraft { pset, fee })
    }

    pub async fn sign(&self, draft: &LiquidDraft) -> Result<LiquidSigned, LiquidError> {
        let mut pset = draft.pset.clone();
        self.signer.sign(&mut pset).map_err(other)?;
        let tx = self.wollet.lock().await.finalize(&mut pset)?;
        Ok(LiquidSigned { tx })
    }

    /// Sends [signed] and adds it to the wallet. Sending it again is safe:
    /// a server that already has it counts as a success.
    pub async fn broadcast(&self, signed: &LiquidSigned) -> Result<(), LiquidError> {
        let result = self.client.lock().await.broadcast(&signed.tx).await;
        if let Err(error) = result {
            let error = LiquidError::from(error);
            let known = error.kind == LiquidErrorKind::Rejected
                && error.message.to_lowercase().contains("already");
            if !known {
                return Err(error);
            }
        }
        self.wollet
            .lock()
            .await
            .apply_transaction(signed.tx.clone())?;
        Ok(())
    }
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[cfg(test)]
mod tests {
    use super::*;

    const ABANDON: &str =
        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";

    fn same_descriptor(ours: String, expected: &str) {
        let expected: WolletDescriptor = expected.parse().unwrap();
        assert_eq!(ours, expected.to_string());
    }

    // From LWK's own tests. The blinding key is SLIP-77's test vector.
    #[test]
    fn a_known_phrase_gives_known_descriptors() {
        same_descriptor(
            descriptor(ABANDON.into(), LiquidNetwork::Mainnet, ScriptKind::NativeSegwit).unwrap(),
            "ct(slip77(9c8e4f05c7711a98c838be228bcb84924d4570ca53f35fa1c793e58841d47023),elwpkh([73c5da0a/84h/1776h/0h]xpub6CRFzUgHFDaiDAQFNX7VeV9JNPDRabq6NYSpzVZ8zW8ANUCiDdenkb1gBoEZuXNZb3wPc1SVcDXgD2ww5UBtTb8s8ArAbTkoRQ8qn34KgcY/<0;1>/*))#y8jljyxl",
        );
        same_descriptor(
            descriptor(ABANDON.into(), LiquidNetwork::Testnet, ScriptKind::NativeSegwit).unwrap(),
            "ct(slip77(9c8e4f05c7711a98c838be228bcb84924d4570ca53f35fa1c793e58841d47023),elwpkh([73c5da0a/84h/1h/0h]tpubDC8msFGeGuwnKG9Upg7DM2b4DaRqg3CUZa5g8v2SRQ6K4NSkxUgd7HsL2XVWbVm39yBA4LAxysQAm397zwQSQoQgewGiYZqrA9DsP4zbQ1M/<0;1>/*))#xte2lx9x",
        );
        let nested =
            descriptor(ABANDON.into(), LiquidNetwork::Mainnet, ScriptKind::NestedSegwit).unwrap();
        assert!(nested.contains(",elsh(wpkh([73c5da0a/49'/1776'/0']"), "{nested}");
    }

    #[tokio::test]
    async fn a_known_phrase_gives_known_addresses() {
        let wallet = LiquidWallet::open(
            ABANDON.into(),
            LiquidNetwork::Mainnet,
            ScriptKind::NativeSegwit,
            "http://127.0.0.1:9".into(),
            vec![],
        )
        .await
        .unwrap();
        let first = wallet.address(None).await.unwrap();
        assert_eq!(first.index, 0);
        assert_eq!(first.address, FIRST_MAINNET_ADDRESS);
        assert_eq!(wallet.balance().await.unwrap(), 0);
        assert!(wallet.transactions().await.unwrap().is_empty());
    }

    // Recorded from this code, to catch a change in how addresses derive.
    const FIRST_MAINNET_ADDRESS: &str = "lq1qqvxk052kf3qtkxmrakx50a9gc3smqad2ync54hzntjt980kfej9kkfe0247rp5h4yzmdftsahhw64uy8pzfe7cpg4fgykm7cv";

    #[test]
    fn phrases_are_checked() {
        assert!(phrase_problem(ABANDON.into()).is_none());
        assert!(matches!(
            phrase_problem(ABANDON.replace("about", "abandon")),
            Some(PhraseProblem::Checksum)
        ));
        assert!(matches!(
            phrase_problem(ABANDON.replace("about", "abuot")),
            Some(PhraseProblem::UnknownWord)
        ));
        assert!(matches!(
            phrase_problem("abandon about".into()),
            Some(PhraseProblem::WordCount)
        ));
        let fresh = generate_phrase().unwrap();
        assert_eq!(fresh.split(' ').count(), 12);
        assert!(phrase_problem(fresh).is_none());
    }

    #[tokio::test]
    async fn sending_checks_the_address() {
        let wallet = LiquidWallet::open(
            ABANDON.into(),
            LiquidNetwork::Mainnet,
            ScriptKind::NativeSegwit,
            "http://127.0.0.1:9".into(),
            vec![],
        )
        .await
        .unwrap();
        let testnet = "tlq1qq02egjncr8g4qn890mrw3jhgupwqymekv383lwpmsfghn36hac5ptpmeewtnftluqyaraa56ung7wf47crkn5fjuhk422d68m";
        let error = wallet.prepare_send(testnet.into(), 1000).await.err().unwrap();
        assert_eq!(error.kind, LiquidErrorKind::WrongNetwork);

        let error = wallet.prepare_send("lq1nope".into(), 1000).await.err().unwrap();
        assert_eq!(error.kind, LiquidErrorKind::InvalidAddress);

        let own = wallet.address(Some(3)).await.unwrap().address;
        let error = wallet.prepare_send(own, 1000).await.err().unwrap();
        assert_eq!(error.kind, LiquidErrorKind::InsufficientFunds);
    }

    #[tokio::test]
    async fn an_unreachable_server_is_reported_as_such() {
        let wallet = LiquidWallet::open(
            ABANDON.into(),
            LiquidNetwork::Mainnet,
            ScriptKind::NativeSegwit,
            "http://127.0.0.1:9".into(),
            vec![],
        )
        .await
        .unwrap();
        let error = wallet.sync().await.err().unwrap();
        assert_eq!(error.kind, LiquidErrorKind::Unreachable);
    }
}
