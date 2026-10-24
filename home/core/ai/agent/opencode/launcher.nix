{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  upstreamPkgs = inputs.opencode.inputs.nixpkgs.legacyPackages.${system};
  patchedSource = pkgs.applyPatches {
    name = "opencode-nix-persistent-pty-source";
    src = inputs.opencode.outPath;
    patches = [ ./patches/nix-persistent-pty.patch ];
  };
  upstreamNodeModules = inputs.opencode.packages.${system}.opencode.node_modules;
  # The v2.1.3 tag ships a stale x86_64-linux node_modules hash; drop this once a tag matches.
  nodeModules =
    assert lib.assertMsg (
      upstreamNodeModules.outputHash == "sha256-y9Zr4/sIxFh5i/6AYl/1N9PzdFBfPnyXEyjqW/idPes="
    ) "OpenCode's upstream node_modules hash changed; remove the local hash override in launcher.nix";
    upstreamNodeModules.overrideAttrs {
      outputHash = "sha256-UCy68yJ2yQSKL7EjmhEEEHrDnPvo/Btpb6krn7rSAeQ=";
    };
  upstream = upstreamPkgs.callPackage "${patchedSource}/nix/opencode.nix" {
    node_modules = nodeModules;
  };
  bun = upstreamPkgs.bun;
  package = upstream.overrideAttrs (old: {
    # Embed the selected release tag's version; flake.lock retains commit provenance.
    __intentionallyOverridingVersion = true;
    version =
      (builtins.fromJSON (builtins.readFile "${inputs.opencode.outPath}/packages/cli/package.json"))
      .version;
    patches = (old.patches or [ ]) ++ [
      ./patches/plugin-resolution.patch
    ];
  });
  wrapped = pkgs.writeShellScriptBin "opencode" ''
    set +x
    honcho_token=${lib.escapeShellArg "${config.xdg.dataHome}/opencode/credentials/honcho-token"}
    honcho_credentials=${lib.escapeShellArg "${config.xdg.dataHome}/opencode/credentials"}
    honcho_fail() {
      printf '%s\n' 'OpenCode Honcho: require an owned, non-symlink 0700 credentials directory and 0600 regular token file containing a nonempty JWT.' >&2
      exit 1
    }
    unset HONCHO_API_KEY HONCHO_URL HONCHO_BASE_URL HONCHO_WORKSPACE HONCHO_WORKSPACE_ID HONCHO_PEER_NAME HONCHO_AI_PEER
    honcho_uid=$(${pkgs.coreutils}/bin/id -u) || honcho_fail
    [[ -d "$honcho_credentials" && ! -L "$honcho_credentials" ]] || honcho_fail
    [[ "$(${pkgs.coreutils}/bin/stat -c '%u:%a' -- "$honcho_credentials")" == "$honcho_uid:700" ]] || honcho_fail
    [[ -f "$honcho_token" && ! -L "$honcho_token" && -r "$honcho_token" ]] || honcho_fail
    [[ "$(${pkgs.coreutils}/bin/stat -c '%u:%a' -- "$honcho_token")" == "$honcho_uid:600" ]] || honcho_fail
    HONCHO_API_KEY=$(< "$honcho_token") || honcho_fail
    [[ "$HONCHO_API_KEY" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]] || honcho_fail
    export HONCHO_API_KEY
    export OPENCODE_HONCHO_CONFIG_PATH=${lib.escapeShellArg "${config.xdg.configHome}/opencode/honcho.json"}
    unset honcho_token honcho_credentials honcho_uid
    unset -f honcho_fail
    export PATH="${
      lib.makeBinPath [
        bun
        pkgs.nodejs
      ]
    }:$PATH"
    export OPENCODE_CLEAR_ENCRYPTED_BUN=${lib.getExe bun}
    exec ${lib.getExe package} "$@"
  '';
in
{
  home.packages = [ wrapped ];
}
