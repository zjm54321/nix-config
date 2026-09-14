{ pkgs, ... }:
{
  users.users.ming = {
    isNormalUser = true;
    description = "章家铭";
    extraGroups = [ "wheel" ];
    shell = pkgs.nushell;
  };

  programs.nushell.enable = true;
}
