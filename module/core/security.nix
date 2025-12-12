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

    # howdy
    { disabledModules = [ "security/pam.nix" ]; }
    "${inputs.howdy}/nixos/modules/security/pam.nix"
    "${inputs.howdy}/nixos/modules/services/security/howdy"
    "${inputs.howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"
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
      /*
        假如是从 Windows Bitlocker 切换而来:
        `echo 5 > /sys/class/tpm/tpm0/ppi/request`
        https://askubuntu.com/questions/1357694/trying-to-understand-errors-from-tpm2-toolshttps://askubuntu.com/questions/1357694/trying-to-understand-errors-from-tpm2-tools
      */
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
