{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./vscode ];

  options.dev.nix.enable = lib.mkEnableOption "启用 Nix 开发环境";

  config = lib.mkIf config.dev.nix.enable {
    vscode.nix.enable = true;

    home.packages = with pkgs; [
      nixfmt-rfc-style
      nil
    ];
  };
}
