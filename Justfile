set shell := ["bash", "-uc"]

default:
    @just --list

# Rebuild a NixOS configuration, defaulting to the current hostname.
switch host=`hostname`:
    sudo nixos-rebuild switch --flake "path:.#{{host}}"

# Format the complete working tree, including untracked Nix files.
fmt:
    nix fmt path:.

# Evaluate and check the flake.
check:
    nix flake check path:.
