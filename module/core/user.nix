{ pkgs, ... }:
{
  users.users.ming = {
    isNormalUser = true;
    description = "章家铭";
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
  };

  programs.bash.interactiveShellInit = ''
    if [[ -n "''${TERM-}" && "$TERM" != dumb && -t 0 ]]; then
      exec ${pkgs.nushell}/bin/nu
    fi
  '';

  programs.nushell.enable = true;
}
