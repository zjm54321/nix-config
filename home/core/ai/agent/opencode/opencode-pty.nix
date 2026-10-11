{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  nodejs,
  autoPatchelfHook,
}:
let
  pname = "opencode-pty";
  version = "0.4.0-unstable-2026-10-01";
  src = fetchFromGitHub {
    owner = "shekohex";
    repo = pname;
    # TODO: return to a release once it includes the V2 registration and sidebar improvements.
    rev = "b6c2067f1fb29d5fd3b2e744a7c05d7df1a6e7c1";
    hash = "sha256-1jT78doh4eaTO7fBfl9P7Lj3AcG5w4HnIYUAp8pd4E0=";
  };
  nodeModules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node-modules";
    inherit version src;
    nativeBuildInputs = [ bun ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      export HOME="$TMPDIR/home"
      export BUN_INSTALL_CACHE_DIR="$TMPDIR/bun-cache"
      mkdir -p "$HOME" "$BUN_INSTALL_CACHE_DIR"
      bun install --frozen-lockfile --ignore-scripts --backend copy --no-progress
      cmp bun.lock ${src}/bun.lock
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -R node_modules "$out"
      runHook postInstall
    '';
    dontFixup = true;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-eYq23f/5XCZUNfaLOFsAg6VfcW+sD6UHQsGIxXJZITo=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = [
    bun
    nodejs
    autoPatchelfHook
  ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontConfigure = true;

  # Upstream invokes unpinned `bun x copyfiles`, absent from bun.lock. Copy the
  # same text resources with coreutils instead, keeping the build offline.
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail 'bun x copyfiles -u 0 \"src/**/*.txt\" dist' \
        'find src -type f -name \"*.txt\" -exec cp --parents {} dist/ \\;'
  '';

  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR/home"
    export BUN_INSTALL_CACHE_DIR="$TMPDIR/bun-cache"
    mkdir -p "$HOME" "$BUN_INSTALL_CACHE_DIR"
    cp -R ${nodeModules} node_modules
    chmod -R u+w node_modules
    patchShebangs node_modules
    bun run build:prod
    cmp bun.lock ${src}/bun.lock
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp ${src}/package.json "$out/package.json"
    cp -R dist node_modules LICENSE "$out/"
    runHook postInstall
  '';

  passthru = {
    inherit nodeModules;
  };
  meta = {
    description = "OpenCode PTY plugin with its V2 entry point and native Bun PTY library";
    homepage = "https://github.com/shekohex/opencode-pty";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
