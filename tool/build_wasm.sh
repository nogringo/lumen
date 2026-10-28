#!/usr/bin/env bash
# Builds lumen_core for the web into web/pkg/, which the web app loads once a
# Liquid wallet opens. Run it before `flutter run -d chrome` or `flutter build web`.
set -euo pipefail
cd "$(dirname "$0")/.."
web=$PWD/web

# flutter_rust_bridge builds the standard library too (-Z build-std), which
# needs nightly. Pinned, so a broken nightly cannot break the deploy.
toolchain=nightly-2026-10-11
rustup toolchain install "$toolchain" --no-self-update --profile minimal \
  --component rust-src,llvm-tools --target wasm32-unknown-unknown

# Apple's ar silently writes empty archives for wasm objects (ring, secp256k1-sys).
host=$(rustc "+$toolchain" -vV | sed -n 's/host: //p')
AR_wasm32_unknown_unknown="$(rustc "+$toolchain" --print sysroot)/lib/rustlib/$host/bin/llvm-ar"
export AR_wasm32_unknown_unknown

# No atomics: threads need COOP and COEP headers, which GitHub Pages cannot send.
# The output is absolute because wasm-pack reads a relative one from the crate.
cd packages/lumen_core
dart run flutter_rust_bridge build-web --release --output "$web" \
  --wasm-pack-rustup-toolchain "$toolchain" \
  --wasm-pack-rustflags '-C target-feature=+bulk-memory,+mutable-globals'
