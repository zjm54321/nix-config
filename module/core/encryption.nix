{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  options.services.secureboot.enable = mkEnableOption "配置安全启动";

  config = mkIf config.services.secureboot.enable {
    environment.systemPackages = [ pkgs.sbctl ];
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

}
