{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # Pinned upstream needs this Bun ResolveMessage compatibility patch.
  package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./plugin-resolution.patch ];
  });
  wrapped = pkgs.writeShellScriptBin "opencode2" ''
    export XDG_CONFIG_HOME="$HOME/.config/opencode2"
    export XDG_DATA_HOME="$HOME/.local/share/opencode2"
    export XDG_CACHE_HOME="$HOME/.cache/opencode2"
    export XDG_STATE_HOME="$HOME/.local/state/opencode2"
    export OPENCODE_LOG_DIR="$XDG_DATA_HOME/opencode/log"
    export PATH="${pkgs.lib.makeBinPath [ pkgs.bun ]}:$PATH"
    unset OPENCODE_CONFIG OPENCODE_CONFIG_DIR OPENCODE_CONFIG_CONTENT OPENCODE_DB
    export OPENCODE_DISABLE_PROJECT_CONFIG=1
    exec ${lib.getExe package} "$@"
  '';
in
{
  home.packages = [ wrapped ];

  xdg.configFile."opencode2/git/config".text = ''
    [include]
      path = ${config.xdg.configHome}/git/config
  '';

  home.activation.opencode2ServicePort = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe wrapped} service set port 49375
  '';
}
