{
  config,
  lib,
  pkgs,
  systemFlakeHost,
  ...
}:
let
  json = pkgs.formats.json { };
  agentsTemplate = pkgs.replaceVars ./AGENTS.md {
    inherit systemFlakeHost;
  };
  baseSettings = builtins.fromJSON (builtins.readFile ./opencode.json);
  omoConfig = builtins.fromJSON (builtins.readFile ./oh-my-opencode-slim.json);
  # Temporary V1 wire compatibility for EEHUB Google; remove if repointed to direct Google.
  originalProviders = lib.recursiveUpdate (import ./providers.nix) {
    google.options.omitFunctionCallIds = true;
  };
  inherit
    (import ./plugins {
      inherit lib pkgs originalProviders;
    })
    modelPolicy
    resolvePlugin
    ;
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
    "billion-context/billion-context.json" = {
      target = "billion-context/billion-context.json";
      source = ./billion-context.json;
      force = true;
    };

    # Keep distinct declaration keys: V1 owns opencode/* keys redirected to oc1.
    "opencode-config" = {
      target = "opencode/opencode.json";
      source = json.generate "opencode.json" (
        builtins.removeAttrs baseSettings [ "$comment" ]
        // {
          shell = lib.getExe pkgs.bashInteractive;
          enabled_providers = builtins.attrNames originalProviders;
          plugins = map resolvePlugin baseSettings.plugins;
          provider = builtins.removeAttrs modelPolicy.providers [ "openai" ];
          providers.openai.settings = modelPolicy.providers.openai.options // {
            transport = "http";
          };
          mcp = mcpServers;
          permission = import ./permissions.nix;
        }
      );
    };
    "opencode-honcho" = {
      target = "opencode/honcho.json";
      source = ./honcho.json;
    };
    "opencode-cli" = {
      target = "opencode/cli.json";
      source = ./cli.json;
    };
    "opencode-slim" = {
      target = "opencode/oh-my-opencode-slim.json";
      source = json.generate "opencode-oh-my-opencode-slim.json" omoConfig;
    };
    "opencode-instructions" = {
      target = "opencode/AGENTS.md";
      source = agentsTemplate;
    };
    "opencode-raw-agent" = {
      target = "opencode/agents/raw.md";
      source = ./raw.md;
    };
  };
}
