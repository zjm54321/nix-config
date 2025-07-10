{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    remmina
  ];

  programs = {
    wiliwili.enable = true;
  };
  gui.de = "niri";

  # GPG 设备密钥
  programs.git.signing = lib.mkForce {
    format = "openpgp";
    key = "7F7AE88A93D45341";
  };
  services.gpg-agent.sshKeys = [
    # gpg --list-keys --with-keygrip
    "10D278B429062414335B1C5220EF20998B36C60C"
  ];
}
