#!/usr/bin/env python3
import hashlib
import importlib.util
import os
import stat
import tempfile
import unittest
from unittest import mock
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("writable-config.py")
SPEC = importlib.util.spec_from_file_location("writable_config", MODULE_PATH)
writable_config = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(writable_config)


class WritableConfigTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="codex-writable-tests-", dir="/tmp/opencode")
        self.root = Path(self.temp.name)
        self.baseline = self.root / "baseline.toml"
        self.target = self.root / ".codex" / "config.toml"
        self.state = self.root / ".codex" / ".hm-config-state"
        self.target.parent.mkdir(mode=0o700)
        self.baseline.write_bytes(b"model = 'baseline'\n")

    def tearDown(self):
        self.temp.cleanup()

    def marker(self):
        return (self.state / "baseline.sha256").read_text().strip()

    def backups(self):
        return list((self.state / "backups").iterdir())

    def test_fresh_seed_and_idempotence(self):
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), self.baseline.read_bytes())
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(stat.S_IMODE(self.target.stat().st_mode), 0o600)
        first_backups = self.backups()
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertEqual(self.backups(), first_backups)

    def test_unchanged_baseline_preserves_atomic_codex_save(self):
        writable_config.seed(self.baseline, self.target, self.state, False)
        replacement = self.target.with_name("codex-save")
        replacement.write_bytes(b"model = 'baseline'\n[projects]\n'/tmp' = { trust_level = 'trusted' }\n")
        os.chmod(replacement, 0o600)
        os.replace(replacement, self.target)
        before = self.target.read_bytes()
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), before)
        self.assertEqual(stat.S_IMODE(self.target.stat().st_mode), 0o600)

    def test_same_bytes_different_baseline_path_preserves_edits(self):
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.target.write_bytes(b"user edit\n")
        other = self.root / "same-bytes.toml"
        other.write_bytes(self.baseline.read_bytes())
        writable_config.seed(other, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), b"user edit\n")

    def test_changed_baseline_backs_up_and_reseeds(self):
        writable_config.seed(self.baseline, self.target, self.state, False)
        old = b"user trust\n"
        self.target.write_bytes(old)
        self.baseline.write_bytes(b"model = 'new baseline'\n")
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), self.baseline.read_bytes())
        self.assertIn(old, [path.read_bytes() for path in self.backups()])
        self.assertEqual(self.marker(), hashlib.sha256(self.baseline.read_bytes()).hexdigest())

    def test_legacy_symlink_backup_then_seed(self):
        legacy = self.root / "legacy.toml"
        legacy.write_bytes(b"legacy config\n")
        self.target.symlink_to(legacy)
        writable_config.backup_legacy(self.target, self.state, False)
        self.assertIn(b"legacy config\n", [path.read_bytes() for path in self.backups()])
        self.target.unlink()  # Simulates Home Manager removing the old managed link.
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(legacy.read_bytes(), b"legacy config\n")

    def test_legacy_backup_dry_run_does_not_mutate(self):
        legacy = self.root / "legacy.toml"
        legacy.write_bytes(b"legacy config\n")
        self.target.symlink_to(legacy)
        writable_config.backup_legacy(self.target, self.state, True)
        self.assertTrue(self.target.is_symlink())
        self.assertFalse(self.state.exists())

    def test_dangling_legacy_symlink_is_explicitly_skipped(self):
        self.target.symlink_to(self.root / "missing-legacy.toml")
        self.assertEqual(
            writable_config.backup_legacy(self.target, self.state, False),
            "legacy config symlink is dangling; skipped",
        )
        self.assertTrue(self.target.is_symlink())
        self.assertFalse(self.state.exists())

    def test_unreadable_legacy_symlink_fails_without_backup(self):
        legacy = self.root / "legacy.toml"
        legacy.write_bytes(b"legacy config\n")
        self.target.symlink_to(legacy)
        with mock.patch.object(
            writable_config,
            "read_symlink_target",
            side_effect=writable_config.ConfigError("cannot read runtime config symlink target"),
        ):
            with self.assertRaises(writable_config.ConfigError):
                writable_config.backup_legacy(self.target, self.state, False)
        self.assertTrue(self.target.is_symlink())
        self.assertEqual(legacy.read_bytes(), b"legacy config\n")
        self.assertFalse(self.state.exists())

    def test_seed_replaces_symlink_without_writing_its_target(self):
        legacy = self.root / "legacy.toml"
        legacy.write_bytes(b"legacy config\n")
        self.target.symlink_to(legacy)
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(legacy.read_bytes(), b"legacy config\n")

    def test_missing_target_and_stale_marker_recover(self):
        self.state.mkdir()
        (self.state / "backups").mkdir()
        (self.state / "baseline.sha256").write_text("stale\n")
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), self.baseline.read_bytes())

    def test_invalid_baseline_and_target_do_not_destroy(self):
        self.target.write_bytes(b"keep me\n")
        missing = self.root / "missing.toml"
        with self.assertRaises(writable_config.ConfigError):
            writable_config.seed(missing, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), b"keep me\n")
        invalid_baseline = self.root / "baseline-directory"
        invalid_baseline.mkdir()
        with self.assertRaises(writable_config.ConfigError):
            writable_config.seed(invalid_baseline, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), b"keep me\n")
        self.target.unlink()
        self.target.mkdir()
        with self.assertRaises(writable_config.ConfigError):
            writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertTrue(self.target.is_dir())

    def test_symlinked_state_directory_fails_without_replacing_config(self):
        self.target.write_bytes(b"keep me\n")
        outside = self.root / "outside-state"
        outside.mkdir()
        self.state.symlink_to(outside, target_is_directory=True)
        with self.assertRaises(writable_config.ConfigError):
            writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), b"keep me\n")

    def test_backup_failure_keeps_runtime_config_and_marker(self):
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.target.write_bytes(b"user trust\n")
        marker = self.marker()
        backups = self.state / "backups"
        backups.rmdir()
        outside = self.root / "outside-backups"
        outside.mkdir()
        backups.symlink_to(outside, target_is_directory=True)
        self.baseline.write_bytes(b"new baseline\n")
        with self.assertRaises(writable_config.ConfigError):
            writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), b"user trust\n")
        self.assertEqual(self.marker(), marker)

    def test_snapshot_error_keeps_runtime_config_and_marker(self):
        writable_config.seed(self.baseline, self.target, self.state, False)
        self.target.write_bytes(b"user trust\n")
        marker = self.marker()
        self.baseline.write_bytes(b"new baseline\n")
        with mock.patch.object(
            writable_config,
            "snapshot",
            side_effect=writable_config.ConfigError("cannot create runtime config backup"),
        ):
            with self.assertRaises(writable_config.ConfigError):
                writable_config.seed(self.baseline, self.target, self.state, False)
        self.assertEqual(self.target.read_bytes(), b"user trust\n")
        self.assertEqual(self.marker(), marker)

    def test_dry_run_does_not_mutate(self):
        writable_config.seed(self.baseline, self.target, self.state, True)
        self.assertFalse(self.target.exists())
        self.assertFalse(self.state.exists())


if __name__ == "__main__":
    unittest.main()
