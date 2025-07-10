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
        # 更新时请使用 `nix-prefetch-url https://github.com/zjm54321.gpg`
        source = builtins.fetchurl {
          url = "https://github.com/zjm54321.gpg";
          sha256 = "1iyc1irf77szf9v6bc6ffqyhnybghx2shbx31jqj5ckpw9bwnr9f";
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
