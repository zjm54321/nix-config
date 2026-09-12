{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  upstream = inputs.opencode.packages.${system}.opencode;
  upstreamPkgs = inputs.opencode.inputs.nixpkgs.legacyPackages.${system};
  # Upstream's FOD currently uses Bun 1.3.13. Recheck this hash when its input changes.
  bun = assert lib.assertMsg (system == "x86_64-linux") "OpenCode2's Bun 1.4.2 workaround supports only x86_64-linux";
    upstreamPkgs.bun.overrideAttrs (_: {
      version = "1.4.2";
      src = upstreamPkgs.fetchurl {
        url = "https://github.com/oven-sh/bun/releases/download/bun-v1.4.2/bun-linux-x64.zip";
        hash = "sha256-NjaPrvdSeHXV/6UuU81IAhdB8qg+tiCKjdZAaNQiqRM=";
      };
    });
  nodeModules = assert lib.assertMsg
    (upstream.node_modules.outputHash == "sha256-yzCk746pospz8EVakHRcDhYJkhGYGSt9dHOPbzO4OYo=")
    "OpenCode's node_modules hash changed; refresh the local Bun 1.4.2 dependency hash/workaround";
    upstream.node_modules.override {
      inherit bun;
      hash = "sha256-I8VHWUQjNNbfIrwWwWrsFKyazAEPa/zqUhFqhvpQ9/8=";
    };
  # Pinned upstream still needs this Bun ResolveMessage compatibility patch.
  package = (upstream.override {
    inherit bun;
    node_modules = nodeModules;
  }).overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./plugin-resolution.patch ];
    # Upstream CLI emits `opencode`; retain the local `opencode2` output name.
    installPhase = lib.replaceStrings [ "dist/cli-*/bin/opencode2" ] [ "dist/cli-*/bin/opencode" ] old.installPhase;
  });
  wrapped = pkgs.writeShellScriptBin "opencode2" ''
    export OPENCODE_CONFIG_DIR="$HOME/.config/opencode2/opencode"
    export XDG_DATA_HOME="$HOME/.local/share/opencode2"
    export XDG_CACHE_HOME="$HOME/.cache/opencode2"
    export XDG_STATE_HOME="$HOME/.local/state/opencode2"
    export OPENCODE_DB="$XDG_DATA_HOME/opencode/opencode.db"
    export OPENCODE_LOG_DIR="$XDG_DATA_HOME/opencode/log"
    export PATH="${pkgs.lib.makeBinPath [ bun ]}:$PATH"
    unset OPENCODE_CONFIG OPENCODE_CONFIG_CONTENT
    export OPENCODE_DISABLE_PROJECT_CONFIG=1
    exec ${lib.getExe package} "$@"
  '';
in
{
  home.packages = [ wrapped ];

  home.activation.opencode2ServicePort = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    serviceConfig="$HOME/.config/opencode2/opencode/service.json"
    if [[ -e "$serviceConfig" ]]; then
      if ! port="$(${pkgs.jq}/bin/jq -er 'if (.port | type) == "number" then .port else error("service .port must be numeric") end' "$serviceConfig")"; then
        _error "OpenCode2 service configuration has no numeric .port: $serviceConfig"
        exit 1
      fi
      if [[ "$port" == 49375 ]]; then
        :
      elif ${pkgs.procps}/bin/pgrep -u "$UID" -x .opencode2-wrap >/dev/null; then
        _error "OpenCode2 service is active with port $port; refusing to change it during activation"
        exit 1
      else
        run ${lib.getExe wrapped} service set port 49375
      fi
    else
      run ${lib.getExe wrapped} service set port 49375
    fi
  '';
}
