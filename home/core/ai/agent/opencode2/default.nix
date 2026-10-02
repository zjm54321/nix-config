{
  config,
  lib,
  pkgs,
  systemFlakeHost,
  ...
}:
let
  json = pkgs.formats.json { };
  agentsTemplate = pkgs.replaceVars ../opencode/AGENTS.md {
    inherit systemFlakeHost;
  };
  baseSettings = builtins.fromJSON (builtins.readFile ./opencode.json);
  omoConfig = lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ../opencode/oh-my-opencode-slim.json)) (
    builtins.fromJSON (builtins.readFile ./oh-my-opencode-slim.overrides.json)
  );
  # Temporary V1 wire compatibility for EEHUB Google; remove if repointed to direct Google.
  originalProviders = lib.recursiveUpdate (import ../opencode/providers.nix) {
    google.options.omitFunctionCallIds = true;
  };
  modelPolicy = import ./model-policy.nix {
    inherit lib pkgs originalProviders;
  };
  mcpServers = lib.mapAttrs (
    _: server:
    {
      type = "local";
      command = [ server.command ] ++ server.args;
      enabled = server.enabled;
    }
    // lib.optionalAttrs (server.env != { }) { environment = server.env; }
  ) config.programs.mcp.servers;
in
{
  imports = [ ./launcher.nix ];

  xdg.configFile = {
    "opencode2/opencode/opencode.json".source = json.generate "opencode2.json" (
      baseSettings
      // {
        shell = lib.getExe pkgs.bashInteractive;
        enabled_providers = builtins.attrNames originalProviders;
        disabled_providers = (import ../opencode/base.nix).disabled_providers;
        plugin = baseSettings.plugin ++ [ "file://${modelPolicy.package}" ];
        provider = builtins.removeAttrs modelPolicy.providers [ "openai" ];
        providers.openai.settings = modelPolicy.providers.openai.options // {
          transport = "http";
        };
        mcp = mcpServers;
        permission = import ../opencode/premission.nix;
      }
    );

    "opencode2/opencode/cli.json".source = ./cli.json;

    "opencode2/opencode/oh-my-opencode-slim.json".source =
      json.generate "opencode2-oh-my-opencode-slim.json" omoConfig;
    "opencode2/opencode/AGENTS.md".source = agentsTemplate;
    "opencode2/opencode/agents/raw.md".source = ../opencode/raw.md;
  };
}
