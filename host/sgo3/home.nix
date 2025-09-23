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

  dev.environments = [
    "nix"
    "embedded-c51"
  ];

  gui.de = "niri";

  # GPG 设备密钥
  programs.git.signing = lib.mkForce {
    format = "openpgp";
    key = "216D587619D7ABA4";
  };
  services.gpg-agent.sshKeys = [
    # gpg --list-keys --with-keygrip
    "7D29475CD6D37F6ABEBDBA45682E3C88ACE9FFEA"
  ];
}
