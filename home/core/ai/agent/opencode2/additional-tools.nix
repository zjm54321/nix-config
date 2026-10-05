{ pkgs }:
let
  packageJson = pkgs.writeText "opencode2-additional-tools-package.json" (
    builtins.toJSON {
      name = "openai-additional-tools";
      version = "0.0.1";
      type = "module";
      exports = {
        "." = "./index.js";
        "./server" = "./index.js";
      };
    }
  );
in
pkgs.runCommand "opencode2-openai-additional-tools" { } ''
  install -Dm644 ${packageJson} "$out/package.json"
  install -Dm644 ${./additional-tools.js} "$out/index.js"
''
