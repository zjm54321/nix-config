{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    google-chrome
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
