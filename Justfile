set shell := ["nu", "-c"]

default:
    @just --list

# Rebuild the sole NixOS-WSL configuration.
switch:
    sudo nixos-rebuild switch --flake path:.#136kf

# Format the complete working tree, including untracked Nix files.
fmt:
    nix fmt

# Evaluate and check the flake.
check:
    nix flake check path:.
