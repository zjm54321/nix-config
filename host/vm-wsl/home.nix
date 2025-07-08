{
  lib,
  ...
}:
{
  imports = [
    ../../home
  ];
  gui.de = "i3";

  # GPG 设备密钥
  programs.git.signing = lib.mkForce {
    format = "openpgp";
    key = "143CA697734657CE";
  };
  services.gpg-agent.sshKeys = [
    # gpg --list-keys --with-keygrip
    "5A433DADDC09F1A4CC6E10393B50EA54D53F6242"
  ];
}
