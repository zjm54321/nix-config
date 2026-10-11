{
  pkgs,
  systemFlakeHost,
  ...
}:
let
  bash = pkgs.lib.getExe pkgs.bashInteractive;
  base = import ./base.nix;
  premission = import ./premission.nix;
  tui = import ./tui.nix;
  providers = import ./providers.nix;
  plugins = import ./plugins.nix;
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
in
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencodeWithFeatures;
    inherit tui;
    agents.raw = ./raw.md;
    settings = base // {
      shell = bash;
      agent = agents;
      permission = premission;
      plugin = plugins;
      provider = providers;
    };
  };

  # Retain Home Manager's typed settings, MCP integration and ordered JSON
  # generator; only redirect its output targets away from V2's standard tree.
  xdg.configFile."opencode/opencode.json".target = "oc1/opencode/opencode.json";
  xdg.configFile."opencode/tui.json".target = "oc1/opencode/tui.json";
  xdg.configFile."opencode/agents/raw.md".target = "oc1/opencode/agents/raw.md";
  xdg.configFile."opencode/oh-my-opencode-slim.json".target = "oc1/opencode/oh-my-opencode-slim.json";
  xdg.configFile."opencode/oh-my-opencode-slim/default/orchestrator_append.md".target =
    "oc1/opencode/oh-my-opencode-slim/default/orchestrator_append.md";
  xdg.configFile."opencode/AGENTS.md".target = "oc1/opencode/AGENTS.md";

  xdg.configFile."opencode/oh-my-opencode-slim.json".source = ./oh-my-opencode-slim.json;
  xdg.configFile."opencode/oh-my-opencode-slim/default/orchestrator_append.md".source =
    ./prompts/orchestrator_append.md;
  xdg.configFile."opencode/AGENTS.md".source = agentsTemplate;
}
