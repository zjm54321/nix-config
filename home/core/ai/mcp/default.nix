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
          "--executable-path=${lib.getExe pkgs.google-chrome}"
          "--no-usage-statistics"
        ];
        enabled = true;
      };
    };
  };
}
