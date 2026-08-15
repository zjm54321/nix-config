# NixOS System Environment

## Environment identity

This AI is running inside a declarative NixOS system:

- Platform: NixOS on WSL2
- WSL distribution: `nixos`
- Linux hostname: `nix`
- Linux user: `ming`
- System Flake output: `nixosConfigurations.136kf`
- System repository: <https://github.com/zjm54321/nix-config>
- System branch: `wsl`

The Git repository and its locked Flake are the source of truth. Build a reproducible, immutable, declarative environment rather than modifying the live system imperatively. A lock file reduces input drift; it does not promise bit-identical results across every operating system, architecture, Nix version, kernel, or build environment.

## Core principles

1. Declare persistent system and user changes in `nix-config`.
2. Pin dependencies through Flake inputs and `flake.lock`.
3. Treat `/nix/store` as immutable; never edit, delete, chmod, or replace store paths.
4. Do not use `apt`, `apt-get`, global npm installs, or manually copied binaries to create persistent system state.
5. Use `nix shell` only for temporary tools. Add recurring tools to the appropriate NixOS or Home Manager module.
6. Keep secrets, private keys, credentials, caches, and mutable runtime state outside the Git repository and Nix store.
7. Prefer official packages, modules, overlays, and pinned external Flake inputs over ad-hoc installation scripts.
8. Preserve the layered structure: host configuration in `host/136kf`, system modules in `module`, user configuration in `home`, and external Skill sources in `skills`.

## Per-project development environments

- For each software project, prefer a project-local `flake.nix` that declares runtimes, compilers, build tools, and development dependencies through `devShells`.
- Commit the corresponding `flake.lock` so the Flake resolves pinned input revisions or content hashes and avoids unintended input drift.
- Enter the project environment with `nix develop`, or `nix develop .#<name>` when the project exposes multiple shells.
- Do not manage project dependencies through `nix profile`, `nix-env`, or another global installation mechanism. Add recurring project dependencies to the project's development shell.
- Use `nix shell nixpkgs#<package>` for software needed only temporarily and not meant to become persistent project or system state.
- For temporary unfree software, use `NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#<package>`.
- When introducing a Flake into an existing project, first identify its actual toolchain and keep the initial Flake minimal, explicit, and reviewable.
- Keep Flake evaluation pure by default. Use `--impure` only when mutable external state is intentionally required, and state the reproducibility impact.
- `nix profile` is acceptable for long-lived personal software when explicitly requested, but it is not a substitute for declaring project dependencies.
- `direnv` is an optional nix.dev-documented workflow for automatically entering an environment; it does not replace `flake.nix`, `devShells`, or `nix develop`. `nix-direnv` is third-party and must not be described as an official Nix component.

## How to change the system

For persistent changes:

1. Work in `/mnt/c/Users/Zhang/nix-config`.
2. Modify the relevant `.nix` source file.
3. Format and evaluate the Flake.
4. Build the target without activation.
5. Activate only when explicitly requested.
6. Commit reviewed source and lock-file changes so the environment can be reproduced from GitHub.

Run commands from the repository root:

```sh
nix fmt
nix flake check path:.
nix build path:.#nixosConfigurations.136kf.config.system.build.toplevel --no-link
sudo nixos-rebuild build --flake path:.#136kf
```

Activate a verified configuration only when requested:

```sh
sudo nixos-rebuild switch --flake path:.#136kf
```

Useful inspection commands:

```sh
nix flake show path:.
nix eval path:.#nixosConfigurations.136kf.config.networking.hostName
readlink -f /run/current-system
systemctl is-system-running
wslinfo --networking-mode
```

From Windows, enter the configured distribution with:

```powershell
wsl.exe -d nixos -u ming
```

## Package policy

- System-wide packages belong in a NixOS module such as `module/core/packages.nix`.
- User-only tools and program configuration belong in Home Manager under `home/core`.
- Temporary free packages may use `nix shell nixpkgs#<package>`.
- Temporary unfree packages require explicit impure evaluation:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#<package>
```

- Do not replace the official nixpkgs Flake source with a mirror. Binary substituters may use configured mirrors.

## Flake and lock-file policy

- Do not update inputs incidentally.
- When an input change is required, update `flake.lock` deliberately and review the exact revisions.
- Understand that pure evaluation constrains evaluation inputs, while build results may still vary with architecture, kernel, filesystem, Nix version, and other build conditions.
- Keep `system.stateVersion` and `home.stateVersion` unchanged unless performing a deliberate migration.
- Never discard a working lock file to solve an evaluation problem.

## Verification policy

At minimum, persistent Nix changes require:

1. `nix fmt` when the Flake provides a `formatter` output
2. `nix flake check path:.`
3. A focused evaluation or build for the changed component
4. `nixos-rebuild build --flake path:.#136kf` for system changes

After activation, verify actual runtime behavior instead of assuming that successful evaluation proves deployment.

`nixos-rebuild build` builds without activation. `test` switches the running system without making it the next boot default. `boot` sets the next boot generation without switching the current system. `switch` builds, activates, and sets the boot default. Do not run `test`, `boot`, or `switch` unless the user explicitly requests the corresponding effect.

## Safety boundaries

- Do not edit generated files under `/etc`, `/run/current-system`, Home Manager generations, or `/nix/store`; edit their source modules.
- Do not expose ports, alter SSH/firewall/networking, update inputs, or activate a new generation without considering system impact.
- Do not commit secrets, tokens, private keys, activation logs, caches, `result` symlinks, or temporary build output.
- Do not overwrite unrelated working-tree changes.
- Before committing, inspect `git status`, unstaged diff, staged diff, recent commits, and the remote destination.

The desired outcome is an elegant environment that can be reconstructed from the repository and lock files, with mutable state kept separate from immutable configuration.
