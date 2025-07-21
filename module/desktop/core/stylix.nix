{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";

  stylix.autoEnable = lib.mkDefault false; # 不自动启用 Stylix
}
