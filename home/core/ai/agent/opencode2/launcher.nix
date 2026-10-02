{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  bash = lib.getExe pkgs.bashInteractive;
  system = pkgs.stdenv.hostPlatform.system;
  upstream = inputs.opencode.packages.${system}.opencode;
  upstreamPkgs = inputs.opencode.inputs.nixpkgs.legacyPackages.${system};
  bun = upstreamPkgs.bun;
  package = upstream.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./plugin-resolution.patch
      ./gemini-idless-tool-history.patch
    ];
  });
  wrapped = pkgs.writeShellScriptBin "opencode2" ''
    export SHELL="${bash}"
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
    serviceConfig="$HOME/.config/opencode2/opencode/service-prod.json"
    port=""
    if [[ -e "$serviceConfig" ]]; then
      if ! port="$(${pkgs.jq}/bin/jq -er 'if (.port | type) == "number" then .port else error("service .port must be numeric") end' "$serviceConfig")"; then
        _error "OpenCode2 service configuration has no numeric .port: $serviceConfig"
        exit 1
      fi
    fi
    if [[ "$port" == 49375 ]]; then
      :
    elif ${pkgs.procps}/bin/pgrep -u "$UID" -f '^/nix/store/[^/]+-opencode-2\.[^/]+/bin/\.?opencode2?(-wrapped)? serve --service( |$)' >/dev/null; then
      _error "OpenCode2 service is active; refusing to change its port during activation"
      exit 1
    else
      run ${lib.getExe wrapped} service set port 49375
    fi
  '';
}
