{
  lib,
  pkgs,
  originalProviders,
}:
let
  modelPolicy = import ./model-policy.nix {
    inherit lib pkgs originalProviders;
  };
  ptyPackage = pkgs.callPackage ./pty.nix { };
  # Server-only: the upstream sidebar targets an older TUI API.
  ptyPlugin = pkgs.runCommand "opencode-pty-v2" { } ''
    mkdir -p "$out"
    printf '%s\n' '{"name":"opencode-pty-v2","type":"module"}' > "$out/package.json"
    printf '%s\n' "export { default } from '${ptyPackage}/dist/src/v2/index.js';" > "$out/server.js"
  '';
  localPlugins = {
    "nix:model-policy" = modelPolicy.package;
    "nix:pty" = ptyPlugin;
  };
  resolvePlugin =
    spec:
    if lib.hasPrefix "nix:" spec then
      if builtins.hasAttr spec localPlugins then
        "file://${localPlugins.${spec}}"
      else
        throw "Unknown OpenCode Nix plugin: ${spec}"
    else
      spec;
in
{
  inherit modelPolicy resolvePlugin;
}
