{ pkgs, systemFlakeHost, ... }:
let
  base = import ./base.nix;
  providers = import ./providers.nix;
  plugins = import ./plugins.nix;
  agents = import ./agents.nix;
  agentsInstructions = pkgs.replaceVars ./AGENTS.md {
    inherit systemFlakeHost;
  };
in
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    agents.raw = ./raw.md;
    settings = base // {
      agent = agents;
      plugin = plugins;
      provider = providers;
    };
  };

  xdg.configFile."opencode/oh-my-opencode-slim.json".source = ./oh-my-opencode-slim.json;
  xdg.configFile."opencode/AGENTS.md".source = agentsInstructions;
  home.file."AGENTS.md".source = agentsInstructions;
}
