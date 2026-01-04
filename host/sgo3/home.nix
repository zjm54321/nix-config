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
  # 设置熄屏时间
  services.hypridle.settings.listener = [
    {
      timeout = 600; # 10 minutes
      on-timeout = "systemctl suspend-then-hibernate";
      on-resume = "niri msg action power-on-monitors && brightnessctl -r";
    }
  ];

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
