{ pkgs, ... }:
{
  users.users.ming = {
    isNormalUser = true;
    description = "章家铭";
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
  };

  programs.nushell.enable = true;
}
