{ lib, pkgs, ... }:

let
  chromeDevtoolsMcp = pkgs.writeShellApplication {
    name = "chrome-devtools-mcp";
    runtimeInputs = [ pkgs.nodejs_24 ];
    text = ''
      exec npx -y chrome-devtools-mcp@latest "$@"
    '';
  };
in
{
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

      "chrome-devtools" = {
        command = lib.getExe chromeDevtoolsMcp;
        args = [
          "--executable-path=${lib.getExe pkgs.google-chrome}"
          "--no-usage-statistics"
        ];
        enabled = true;
      };
    };
  };
}
