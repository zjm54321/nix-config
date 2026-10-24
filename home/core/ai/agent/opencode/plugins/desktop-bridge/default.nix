{ pkgs }:
let
  # Local source is versioned here; esbuild/Node are pinned by the system flake.lock.
  version = "0.2.0";
  packageJson = pkgs.writeText "opencode-desktop-bridge-package.json" (
    builtins.toJSON {
      name = "opencode-desktop-bridge";
      displayName = "Desktop Bridge";
      inherit version;
      type = "module";
      exports = {
        "." = "./index.js";
        "./server" = "./index.js";
      };
    }
  );
in
pkgs.runCommand "opencode-desktop-bridge-${version}" { nativeBuildInputs = [ pkgs.esbuild ]; } ''
  install -Dm644 ${packageJson} "$out/package.json"
  esbuild ${./src}/index.ts --bundle --format=esm --platform=node --target=node22 --outfile="$out/index.js"
''
