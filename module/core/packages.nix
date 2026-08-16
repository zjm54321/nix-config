{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    google-chrome
    git
    gnumake
    wget
    curl
    gh
    nushell
    helix
    just
    python313
  ];
}
