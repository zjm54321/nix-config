{
  lib,
  pkgs,
  secret,
  ...
}:

let
  edgeAiStartupScript = pkgs.writeText "start-edge-ai.ps1" (builtins.readFile ./start-edge-ai.ps1);
  edgeAiRelayScript = pkgs.writeText "edge-ai-relay.mjs" (builtins.readFile ./edge-ai-relay.mjs);
  windowsCdpRelayScript = pkgs.writeText "windows-cdp-relay.ps1" (
    builtins.readFile ./windows-cdp-relay.ps1
  );
  windowsPowerShell = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe";

  chromeDevtoolsMcp = pkgs.writeShellApplication {
    name = "chrome-devtools-mcp";
    runtimeInputs = [ pkgs.nodejs_24 ];
    text = ''
      exec node \
        ${lib.escapeShellArg edgeAiRelayScript} \
        ${lib.escapeShellArg windowsPowerShell} \
        ${lib.escapeShellArg edgeAiStartupScript} \
        ${lib.escapeShellArg windowsCdpRelayScript} \
        "$@"
    '';
  };

  codegraphWrapped = pkgs.writeShellApplication {
    name = "codegraph";
    runtimeInputs = [ pkgs.nodejs_24 ];
    text = ''
      exec node \
        --liftoff-only \
        --disable-warning=ExperimentalWarning \
        "${pkgs.codegraph}/lib/codegraph/lib/dist/bin/codegraph.js" \
        "$@"
    '';
  };

  context7Mcp = pkgs.writeShellApplication {
    name = "context7-mcp";
    runtimeInputs = [ pkgs.bun ];
    text = ''
      exec bun x --yes @upstash/context7-mcp "$@"
    '';
  };
in
{
  home.packages = [ pkgs.mcp-nixos ];

  programs.mcp = {
    enable = true;

    servers = {
      codegraph = {
        command = lib.getExe codegraphWrapped;
        args = [
          "serve"
          "--mcp"
        ];
        env.CODEGRAPH_NO_DAEMON = "1";
        enabled = true;
      };

      context7 = {
        command = lib.getExe context7Mcp;
        env.CONTEXT7_API_KEY = secret.context7-api-key;
        enabled = true;
      };

      nixos = {
        command = lib.getExe pkgs.mcp-nixos;
        enabled = true;
      };

      "chrome-devtools" = {
        command = lib.getExe chromeDevtoolsMcp;
        args = [
          "--no-usage-statistics"
        ];
        enabled = true;
      };
    };
  };
}
