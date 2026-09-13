{ lib, pkgs, ... }:

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
in
{
  home.packages = [ pkgs.mcp-nixos ];

  programs.mcp = {
    enable = true;

    servers = {
      codegraph = {
        command = lib.getExe pkgs.codegraph;
        args = [
          "serve"
          "--mcp"
        ];
        env.CODEGRAPH_NO_DAEMON = "1";
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
