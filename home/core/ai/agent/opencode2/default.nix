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
  # opencode.json 暂用本地 slim 插件，等待上游 PR #1465 合并并发布包含修复的版本后，可将插件来源恢复为上游包。
  # https://github.com/alvinunreal/oh-my-opencode-slim/pull/1465
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
  additionalTools = import ./additional-tools.nix { inherit pkgs; };
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
      source = ./billion-context.json;
      force = true;
    };

    # Keep distinct declaration keys: V1 owns opencode/* keys redirected to oc1.
    "opencode2/opencode/opencode.json".target = "opencode/opencode.json";
    "opencode2/opencode/honcho.json" = {
      target = "opencode/honcho.json";
      source = ./honcho.json;
    };
    "opencode2/opencode/cli.json".target = "opencode/cli.json";
    "opencode2/opencode/oh-my-opencode-slim.json".target = "opencode/oh-my-opencode-slim.json";
    "opencode2/opencode/AGENTS.md".target = "opencode/AGENTS.md";
    "opencode2/opencode/agents/raw.md".target = "opencode/agents/raw.md";
    "opencode2/opencode/oh-my-opencode-slim/default/orchestrator_append.md".target =
      "opencode/oh-my-opencode-slim/default/orchestrator_append.md";

    "opencode2/opencode/opencode.json".source = json.generate "opencode2.json" (
      baseSettings
      // {
        shell = lib.getExe pkgs.bashInteractive;
        enabled_providers = builtins.attrNames originalProviders;
        disabled_providers = (import ../opencode/base.nix).disabled_providers;
        plugins = baseSettings.plugins ++ [
          "file://${modelPolicy.package}"
          "file://${additionalTools}"
          "file:///home/ming/opencode-hermes-bridge/dist"
          "@honcho-ai/opencode-honcho@0.2.1"
        ];
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
    "opencode2/opencode/oh-my-opencode-slim/default/orchestrator_append.md".source =
      ../opencode/prompts/orchestrator_append.md;
  };
}
