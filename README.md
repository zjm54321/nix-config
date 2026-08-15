# 136kf NixOS-WSL

A minimal, terminal-only NixOS-WSL configuration. The flake exports exactly one
NixOS configuration: `136kf`.

## Included

- NixOS-WSL with systemd, Windows interop and PATH, `/mnt` automounting, and
  Windows GPU driver support
- User `ming` (章家铭)
- Nushell login shell with Starship integration
- Git, Helix (the default editor), Just, and OpenCode
- Windows GnuPG/OpenSSH agent relays through `npiperelay`

No desktop/WSLg stack, local Tailscale daemon, local GPG agent, or local SSH
agent is configured. OpenCode provider authentication is intentionally left to
the user environment/configuration. Git commits are signed by the Windows GPG
agent with signing subkey `143CA697734657CE`.

The relay expects the verified `albertony/npiperelay` executable at
`C:\Users\Zhang\AppData\Local\npiperelay\npiperelay.exe`. Public keys remain in
the WSL GnuPG keyring; private-key and smartcard operations stay on Windows.

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
home/core/agent-relay.nix Windows GPG/OpenSSH agent relays
```

`flake.lock` is updated separately when input revisions change.
