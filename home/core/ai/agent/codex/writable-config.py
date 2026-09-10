#!/usr/bin/env python3
"""Seed a writable Codex config from Home Manager's generated baseline."""

import argparse
import hashlib
import os
import stat
import sys
import tempfile
from pathlib import Path


class ConfigError(RuntimeError):
    pass


def require_regular(path: Path, description: str) -> bytes:
    try:
        info = path.lstat()
    except FileNotFoundError as error:
        raise ConfigError(f"{description} is missing") from error
    if not stat.S_ISREG(info.st_mode):
        raise ConfigError(f"{description} must be a regular file")
    try:
        return path.read_bytes()
    except OSError as error:
        raise ConfigError(f"cannot read {description}") from error


def require_directory(path: Path, description: str, dry_run: bool) -> None:
    try:
        info = path.lstat()
    except FileNotFoundError:
        if dry_run:
            return
        try:
            path.mkdir(mode=0o700, parents=False)
        except OSError as error:
            raise ConfigError(f"cannot create {description}") from error
        return
    if not stat.S_ISDIR(info.st_mode) or stat.S_ISLNK(info.st_mode):
        raise ConfigError(f"{description} must be a non-symlink directory")
    if not dry_run:
        try:
            os.chmod(path, 0o700)
        except OSError as error:
            raise ConfigError(f"cannot secure {description}") from error


def ensure_state_dirs(state_dir: Path, dry_run: bool) -> Path:
    require_directory(state_dir.parent, "Codex config directory", dry_run)
    require_directory(state_dir, "Codex state directory", dry_run)
    backups = state_dir / "backups"
    require_directory(backups, "Codex backup directory", dry_run)
    return backups


def read_regular_target(path: Path) -> bytes:
    return require_regular(path, "runtime config")


def read_symlink_target(path: Path) -> bytes:
    try:
        resolved = path.resolve(strict=True)
    except OSError as error:
        raise ConfigError("runtime config symlink is unreadable") from error
    return require_regular(resolved, "runtime config symlink target")


def snapshot(backups: Path, data: bytes, dry_run: bool) -> None:
    if dry_run:
        return
    name = None
    try:
        fd, name = tempfile.mkstemp(prefix="config.toml.", suffix=".bak", dir=backups)
        with os.fdopen(fd, "wb") as file:
            file.write(data)
            file.flush()
            os.fsync(file.fileno())
        os.chmod(name, 0o600)
    except OSError as error:
        if name is not None:
            try:
                os.unlink(name)
            except FileNotFoundError:
                pass
        raise ConfigError("cannot create runtime config backup") from error


def marker_path(state_dir: Path) -> Path:
    return state_dir / "baseline.sha256"


def read_marker(state_dir: Path) -> str | None:
    path = marker_path(state_dir)
    if not path.exists() and not path.is_symlink():
        return None
    data = require_regular(path, "baseline marker")
    try:
        return data.decode("ascii").strip()
    except UnicodeDecodeError as error:
        raise ConfigError("baseline marker is not ASCII") from error


def atomic_write(path: Path, data: bytes, mode: int) -> None:
    try:
        fd, name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
        try:
            with os.fdopen(fd, "wb") as file:
                file.write(data)
                file.flush()
                os.fsync(file.fileno())
            os.chmod(name, mode)
            os.replace(name, path)
        except BaseException:
            try:
                os.unlink(name)
            except FileNotFoundError:
                pass
            raise
    except OSError as error:
        raise ConfigError(f"cannot atomically write {path.name}") from error


def backup_legacy(target: Path, state_dir: Path, dry_run: bool) -> str:
    if not target.is_symlink():
        return "legacy config is not a symlink; skipped"
    try:
        data = read_symlink_target(target)
    except ConfigError as error:
        try:
            target.resolve(strict=True)
        except FileNotFoundError:
            return "legacy config symlink is dangling; skipped"
        except (OSError, RuntimeError):
            raise error
        raise error
    backups = ensure_state_dirs(state_dir, dry_run)
    snapshot(backups, data, dry_run)
    return "legacy config symlink backed up"


def seed(baseline: Path, target: Path, state_dir: Path, dry_run: bool) -> str:
    baseline_data = require_regular(baseline, "generated baseline")
    baseline_hash = hashlib.sha256(baseline_data).hexdigest()

    target_exists = target.exists() or target.is_symlink()
    target_data = None
    target_kind = "absent"
    if target_exists:
        info = target.lstat()
        if stat.S_ISREG(info.st_mode):
            target_kind = "regular"
            target_data = read_regular_target(target)
        elif stat.S_ISLNK(info.st_mode):
            target_kind = "symlink"
            target_data = read_symlink_target(target)
        else:
            raise ConfigError("runtime config must be a regular file or readable symlink")

    backups = ensure_state_dirs(state_dir, dry_run)
    marker = read_marker(state_dir)
    if target_kind == "regular" and marker == baseline_hash:
        if not dry_run:
            try:
                os.chmod(target, 0o600)
            except OSError as error:
                raise ConfigError("cannot secure runtime config") from error
        return "runtime config preserved"

    if target_data is not None:
        snapshot(backups, target_data, dry_run)
    if dry_run:
        return "runtime config would be seeded"

    atomic_write(target, baseline_data, 0o600)
    atomic_write(marker_path(state_dir), f"{baseline_hash}\n".encode("ascii"), 0o600)
    return "runtime config seeded"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    commands = parser.add_subparsers(dest="command", required=True)
    legacy = commands.add_parser("backup-legacy")
    legacy.add_argument("--target", type=Path, required=True)
    legacy.add_argument("--state-dir", type=Path, required=True)
    seed_parser = commands.add_parser("seed")
    seed_parser.add_argument("--baseline", type=Path, required=True)
    seed_parser.add_argument("--target", type=Path, required=True)
    seed_parser.add_argument("--state-dir", type=Path, required=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        if args.command == "backup-legacy":
            result = backup_legacy(args.target, args.state_dir, args.dry_run)
        else:
            result = seed(args.baseline, args.target, args.state_dir, args.dry_run)
    except ConfigError as error:
        print(f"codex-writable-config: {error}", file=sys.stderr)
        return 1
    print(result)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
