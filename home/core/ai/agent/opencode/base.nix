{
  "$schema" = "https://opencode.ai/config.json";
  shell = "bash";
  default_agent = "orchestrator";
  disabled_providers = [ "opencode" ];
  instructions = [ "~/.config/opencode/AGENTS.md" ];
  permission.external_directory = {
    "*" = "ask";
    "/etc/nixos/**" = "allow";
    "/nix/store/**" = "allow";
  };
}
