{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dev.nix.enable = lib.mkEnableOption "启用 Nix 开发环境";

  config = lib.mkIf config.dev.nix.enable {
    home.packages = with pkgs; [
      nixfmt
      nil
    ];
  };
}
