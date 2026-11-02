{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.opencode-qol.homeManagerModules.default ];

  programs.opencode-qol = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "opencode-qol-wrapper";
      paths = [ inputs.opencode-qol.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/opencode" --set BILI_THROTTLE_429 0
      '';
    };
    settings = builtins.fromJSON (builtins.readFile ./opencode.json);
    slim.settings.preset = "default";
  };
}
