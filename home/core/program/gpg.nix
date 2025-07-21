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
          sha256 = "06dxhchmdih094qrghrfxnwwv41iv8mfa4l5vyrz3i657nkjnwiv";
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
