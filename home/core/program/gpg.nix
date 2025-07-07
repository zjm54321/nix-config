{
  pkgs,
  ...
}:
{
  programs.gpg = {
    enable = true;
    scdaemonSettings.disable-ccid = true;
    publicKeys = [
      {
        # 本人的 GPG 公钥
        source = builtins.fetchurl {
          url = "https://github.com/zjm54321.gpg";
          sha256 = "02lvyp15crcwsxxdb6ppczv0fgj2mf25n3wgd61ncsza4rc941gw";
        };
        trust = 5;
      }
    ];
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableNushellIntegration = true;
    pinentry.package = pkgs.pinentry-gtk2;
  };
}
