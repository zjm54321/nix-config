{
  "$schema" = "https://opencode.ai/config.json";
  shell = "bash";
  default_agent = "orchestrator";
  disabled_providers = [ "opencode" ];
  instructions = [ "~/.config/opencode/AGENTS.md" ];
}
