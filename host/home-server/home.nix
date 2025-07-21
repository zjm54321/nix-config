{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../home
  ];

  # GPG 设备密钥
  programs.git.signing = lib.mkForce {
    format = "openpgp";
    key = "9BE1C8826761AD50";
  };
  services.gpg-agent.sshKeys = [
    # gpg --list-keys --with-keygrip
    "04A28C9934A632C8B21DF0EED256DE3824317D84"
  ];
}
