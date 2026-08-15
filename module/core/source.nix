{ self, ... }:

{
  # Expose the exact source snapshot used by this system generation.
  # The path is immutable and updates automatically on every rebuild.
  environment.etc."nixos/src".source = self.outPath;
}
