{ pkgs, systemFlakeHost, ... }:
let
  base = import ./base.nix;
  premission = import ./premission.nix;
  tui = import ./tui.nix;
  providers = import ./providers.nix;
  plugins = import ./plugins.nix;
  agents = import ./agents.nix;
  opencodeWithFeatures = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true
    export OPENCODE_ENABLE_EXA=1
    exec ${pkgs.lib.getExe pkgs.opencode} "$@"
  '';
  agentsInstructions = pkgs.replaceVars ./AGENTS.md {
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
      agent = agents;
      permission = premission;
      plugin = plugins;
      provider = providers;
    };
  };

  xdg.configFile."opencode/oh-my-opencode-slim.json".source = ./oh-my-opencode-slim.json;
  xdg.configFile."opencode/AGENTS.md".source = agentsInstructions;
}
