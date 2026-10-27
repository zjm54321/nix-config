{
  config,
  inputs,
  lib,
  pkgs,
  systemFlakeHost,
  ...
}:
let
  bash = pkgs.lib.getExe pkgs.bashInteractive;
  base = import ./base.nix;
  permissions = import ./permissions.nix;
  tui = builtins.fromJSON (builtins.readFile ./tui.json);
  providers = import ./providers.nix;
  plugins = builtins.fromJSON (builtins.readFile ./plugins.json);
  agents = import ./agents.nix;
  opencodeWithFeatures = pkgs.writeShellScriptBin "opencode1" ''
    # Isolate this child even when launched from an older V2 process.
    unset OPENCODE_CONFIG_DIR OPENCODE_CONFIG OPENCODE_CONFIG_CONTENT
    unset OPENCODE_DB OPENCODE_LOG_DIR OPENCODE_DISABLE_PROJECT_CONFIG
    unset OPENCODE_TEST_HOME OPENCODE_TUI_CONFIG OPENCODE_DISABLE_CHANNEL_DB
    export XDG_CONFIG_HOME="$HOME/.config/oc1"
    export XDG_DATA_HOME="$HOME/.local/share/oc1"
    export XDG_CACHE_HOME="$HOME/.cache/oc1"
    export XDG_STATE_HOME="$HOME/.local/state/oc1"
    export PATH="${pkgs.lib.makeBinPath [ pkgs.bun ]}:$PATH"
    export SHELL="${bash}"
    export OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true
    export OPENCODE_EXPERIMENTAL_WEBSOCKETS="false"
    export OPENCODE_ENABLE_EXA=1
    exec ${pkgs.lib.getExe pkgs.opencode} "$@"
  '';
  agentsTemplate = pkgs.replaceVars ./AGENTS.md {
    inherit systemFlakeHost;
  };
  # Keep HM's V1 settings/MCP generation, but isolate its declaration keys too.
  # Renaming the keys makes the default targets oc1/opencode/* without touching
  # the generated contents or colliding with QOL's standard opencode/* keys.
  upstreamModule = import "${inputs.home-manager}/modules/programs/opencode.nix" {
    inherit config lib pkgs;
  };
  upstreamConfig = upstreamModule.config.content;
  v1Files = upstreamConfig.xdg.configFile // {
    "opencode/oh-my-opencode-slim.json".source = ./oh-my-opencode-slim.json;
    "opencode/AGENTS.md".source = agentsTemplate;
  };
in
{
  disabledModules = [ "${inputs.home-manager}/modules/programs/opencode.nix" ];
  imports = [
    (
      upstreamModule
      // {
        config = upstreamModule.config // {
          content = upstreamConfig // {
            xdg = upstreamConfig.xdg // {
              configFile = builtins.listToAttrs (
                lib.mapAttrsToList (name: value: {
                  name = "oc1/${name}";
                  inherit value;
                }) v1Files
              );
            };
          };
        };
      }
    )
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencodeWithFeatures;
    inherit tui;
    agents.raw = ./raw.md;
    settings = base // {
      shell = bash;
      agent = agents;
      permission = permissions;
      plugin = plugins;
      provider = providers;
    };
  };
}
