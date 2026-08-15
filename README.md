# 136kf NixOS-WSL

A minimal, terminal-only NixOS-WSL configuration. The flake exports exactly one
NixOS configuration: `136kf`.

## Included

- NixOS-WSL with systemd, Windows interop and PATH, `/mnt` automounting, and
  Windows GPU driver support
- User `ming` (章家铭)
- Nushell login shell with Starship integration
- Git, Helix (the default editor), Just, and OpenCode

No desktop/WSLg stack, local Tailscale daemon, local GPG agent, or local SSH
agent is configured. OpenCode provider authentication is intentionally left to
the user environment/configuration. Git signing is not forced.

## Use

```sh
nixos-rebuild switch --flake path:.#136kf
# or, after activating the configuration:
just switch
```

The `path:.` form includes uncommitted and newly created files. Format and check
the complete tree with:

```sh
nix fmt path:.
nix flake check path:.
# equivalent Just recipes: just fmt; just check
```

## Layout

```text
host/136kf/       Host composition and Home Manager entry point
module/core/      Shared Nix and user configuration
module/wsl/       NixOS-WSL integration
home/core/program/ Terminal program configuration
```

`flake.lock` is updated separately when input revisions change.
