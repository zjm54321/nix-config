{
  config,
  lib,
  pkgs,
  inputs,
  vars,
  ...
}:
with lib;
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options = {
    services.secureboot.enable = mkEnableOption "配置安全启动";
    services.tpm2.enable = mkEnableOption "启用TPM2支持";
  };

  config = mkMerge [
    (mkIf config.services.secureboot.enable {
      environment.systemPackages = [ pkgs.sbctl ];
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    })

    (mkIf config.services.tpm2.enable {
      boot.initrd.systemd.enable = true;
      security.tpm2.enable = true;
      security.tpm2.pkcs11.enable = true;
      security.tpm2.tctiEnvironment.enable = true;
      users.users.${vars.username}.extraGroups = [ "tss" ];
    })

    {
      # GPG 和智能卡支持
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-gtk2;
        settings = {
          default-cache-ttl = 3600;
          max-cache-ttl = 86400;
        };
      };
      hardware.gpgSmartcards.enable = true;
      services.pcscd.enable = true;
      services.udev.packages = with pkgs; [
        yubikey-personalization
        libu2f-host
      ];
    }

  ];
}
