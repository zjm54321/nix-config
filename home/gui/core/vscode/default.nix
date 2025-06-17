{
  pkgs,
  nix-vscode-extensions,
  ...
}:
{

  home.packages = with pkgs; [
    vscodium
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = import ./extensions.nix {
      inherit nix-vscode-extensions pkgs;
    };
    profiles.default.userSettings = pkgs.lib.importJSON ./settings.json;
  };
}
