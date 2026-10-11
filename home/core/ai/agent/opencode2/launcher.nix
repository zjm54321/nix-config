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
    patches = [ ./nix-persistent-pty.patch ];
  };
  upstream = upstreamPkgs.callPackage "${patchedSource}/nix/opencode.nix" {
    node_modules = inputs.opencode.packages.${system}.opencode.node_modules;
  };
  bun = upstreamPkgs.bun;
  package = upstream.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./plugin-resolution.patch
      ./gemini-idless-tool-history.patch
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
    exec ${lib.getExe package} "$@"
  '';
in
{
  home.packages = [ wrapped ];
}
