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

# Confirm that the activated system is healthy.
health:
    @test -e /run/current-system
    nixos-version
    systemctl is-system-running

# Delete system profile generations older than keep, then collect garbage.
cleanup keep="3":
    @keep="{{keep}}"; if ! [[ "$keep" =~ ^[1-9][0-9]*$ ]]; then echo "keep must be a positive integer." >&2; exit 2; fi; if ! listing="$(sudo nix-env --profile /nix/var/nix/profiles/system --list-generations)"; then exit 1; fi; generations=(); while read -r generation _; do [[ -n "$generation" ]] && generations+=("$generation"); done <<< "$listing"; if (( ${#generations[@]} > keep )); then count=$(( ${#generations[@]} - keep )); to_delete=("${generations[@]:0:count}"); printf 'Deleting system generations: %s\n' "${to_delete[*]}"; sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations "${to_delete[@]}"; else echo "Keeping all ${#generations[@]} system generations; running garbage collection."; fi; sudo nix-collect-garbage

# Push with the active GitHub CLI credentials without changing Git config.
push:
    gh auth status --hostname github.com >/dev/null
    git -c credential.helper= -c credential.helper='!gh auth git-credential' push

# Update, format, check, activate, commit, and push from a clean worktree.
upgrade: clean update fmt check switch commit push

# Update, activate, verify, commit, and prune system generations without pushing.
system-update: clean update fmt check switch health commit cleanup
