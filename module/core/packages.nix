{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    gnumake
    wget
    curl
    nushell
    helix
    just
    python313
  ];
}
