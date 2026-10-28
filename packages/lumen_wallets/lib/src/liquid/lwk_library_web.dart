import 'package:lumen_core/lumen_core.dart';

/// The web app loads the wasm from `pkg/`, built by `tool/build_wasm.sh`.
ExternalLibrary openLwkLibrary(String path) =>
    throw UnsupportedError('The web loads LWK from pkg/, not from a path');
