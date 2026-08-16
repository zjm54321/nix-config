set shell := ["bash", "-uc"]

default:
    @just --list

# Refuse to mix an input update with existing worktree changes.
clean:
    @if [[ -n "$(git status --porcelain)" ]]; then echo "Working tree must be clean before upgrading." >&2; exit 1; fi

# Rebuild a NixOS configuration for the current hostname.
switch:
    nixos-rebuild switch --flake "path:.#$(hostname)" --sudo

# Update all locked flake inputs.
update:
    nix flake update --flake path:.

# Format the complete working tree, including untracked Nix files.
fmt:
    nix fmt

# Evaluate and check the flake.
check:
    nix flake check path:.

# Commit the files produced by a clean upgrade, if any.
commit message="chore: update flake inputs":
    git add --all
    @if git diff --cached --quiet; then echo "No changes to commit."; else git commit -m "{{message}}"; fi

# Push with the active GitHub CLI credentials without changing Git config.
push:
    gh auth status --hostname github.com >/dev/null
    git -c credential.helper= -c credential.helper='!gh auth git-credential' push

# Update, format, check, activate, commit, and push from a clean worktree.
upgrade: clean update fmt check switch commit push
