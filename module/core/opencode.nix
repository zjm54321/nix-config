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
      # GitHub republished the playwright-python v1.63.0 source archive. Keep
      # this limited override until nixpkgs refreshes its fixed-output hash.
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          playwright = python-prev.playwright.overrideAttrs (
            old:
            assert final.lib.assertMsg (
              old.version == "1.63.0"
            ) "Refresh the local Playwright source hash override";
            {
              src = final.fetchFromGitHub {
                owner = "microsoft";
                repo = "playwright-python";
                tag = "v${old.version}";
                hash = "sha256-RwIn+0EcHnStjORVFmT7gp4bGjl+qer1FgtI3+aPF2w=";
              };
            }
          );
        })
      ];

      opencode = prev.opencode.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.patchelf ];

        # Temporary workaround for the filesystem/search runtime import cycle
        # in OpenCode 1.18.30/1.18.31. This is sourced from OpenCode PR #49298
        # / issue #48876; remove it once an upstream version includes the fix.
        patches = (old.patches or [ ]) ++ [
          (final.fetchpatch {
            url = "https://github.com/tstachl/opencode/commit/033e0d18a713675f55e855626604b0735a24e365.patch";
            hash = "sha256-ZSZXJFEbKyZLAJC7t8JxKuWLBSVhrF/krRw/IGdzEaw=";
            name = "opencode-fix-filesystem-search-import-cycle";
          })
        ];

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
