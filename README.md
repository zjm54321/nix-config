# 136kf NixOS-WSL

A minimal, terminal-only NixOS-WSL configuration. The flake exports exactly one
NixOS configuration: `136kf`.

## Included

- NixOS-WSL with systemd, Windows interop and PATH, `/mnt` automounting, and
  Windows GPU driver support
- User account `ming`
- Bash login shell, with Nushell and its Starship integration available
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
just switch
just fmt
just check
just upgrade
```

These recipes use `path:.`, which includes uncommitted and newly created files.

`just upgrade` aggregates the existing Just recipes in this order:
`clean -> update -> fmt -> check -> switch -> commit -> push`. A failed step
stops the remaining recipes, so Git commit and push only run after a successful
update, check, and deployment. If there are no changes, `commit` reports that
there is nothing to commit.

Run `direnv allow` once at the repository root. Thereafter, entering the
directory automatically loads the flake devShell through the root `.envrc` and
Home Manager direnv setup. Launch OpenCode from this activated directory; it
needs no direnv-specific plugin.

`just upgrade` requires a clean worktree. For an already modified worktree,
run `just fmt`, `just check`, and `just switch` first, then commit and push the
verified result.

## Layout

```text
host/136kf/       Host composition and Home Manager entry point
module/core/      Shared Nix and user configuration
module/wsl/       NixOS-WSL integration
home/core/program/ Terminal program configuration
home/core/agent-relay.nix Windows GPG/OpenSSH agent relays
```

`flake.lock` is updated separately when input revisions change.
