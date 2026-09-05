{
  "$schema" = "https://opencode.ai/config.json";
  shell = "bash";
  default_agent = "orchestrator";
  disabled_providers = [ "opencode" ];
  instructions = [ "~/.config/opencode/AGENTS.md" ];
  # ACP owns compression.
  compaction = {
    auto = false;
    prune = false;
  };
  lsp = {
    nixd = {
      command = [ "nixd" ];
      extensions = [ ".nix" ];
    };
  };
}
