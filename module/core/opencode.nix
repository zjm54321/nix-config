{ pkgs, ... }:

{
  # Temporary WSL2 workaround for the OpenCode binary produced by Bun in nixpkgs.
  # The packaged `.opencode-wrapped` currently has an invalid ELF PT_LOAD layout
  # on WSL2 and exits with SIGSEGV (139). Re-applying its existing interpreter
  # with patchelf rewrites the ELF layout and makes the binary start normally.
  # Remove this overlay after nixpkgs#520383 / Bun#31023 (Bun PR #31024) is
  # included in the pinned nixpkgs revision and OpenCode works without it.
  nixpkgs.overlays = [
    (final: prev: {
      opencode = prev.opencode.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.patchelf ];

        # Repair before the upstream postInstall because that phase executes
        # OpenCode to generate completions. Appending this workaround would let
        # that first execution crash before the ELF repair can take effect.
        postInstall = ''
          patchelf \
            --set-interpreter \
            "$(patchelf --print-interpreter "$out/bin/.opencode-wrapped")" \
            "$out/bin/.opencode-wrapped"
        ''
        + (old.postInstall or "");
      });
    })
  ];
}
