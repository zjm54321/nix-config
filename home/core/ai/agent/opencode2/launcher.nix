{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  upstreamPkgs = inputs.opencode.inputs.nixpkgs.legacyPackages.${system};
  patchedSource = pkgs.applyPatches {
    name = "opencode-nix-persistent-pty-source";
    src = inputs.opencode.outPath;
    patches = [ ./nix-persistent-pty.patch ];
  };
  upstream = upstreamPkgs.callPackage "${patchedSource}/nix/opencode.nix" {
    node_modules = inputs.opencode.packages.${system}.opencode.node_modules;
  };
  bun = upstreamPkgs.bun;
  package = upstream.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./plugin-resolution.patch
      ./gemini-idless-tool-history.patch
    ];
  });
  wrapped = pkgs.writeShellScriptBin "opencode" ''
    export PATH="${lib.makeBinPath [ bun pkgs.nodejs ]}:$PATH"
    exec ${lib.getExe package} "$@"
  '';
in
{
  home.packages = [ wrapped ];
}
