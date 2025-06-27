{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  options = {
    services.display.niri.enable = lib.mkEnableOption "Niri desktop environment";
  };

  config = mkIf config.services.display.niri.enable {
    services.displayManager.defaultSession = "niri";
    security.pam.services.hyprlock = { };
    i18n.inputMethod.fcitx5.waylandFrontend = true;

    /*
      不使用 niri.overlays.niri，因为它的 Binary Cache 配置比较繁琐
      如果需要使用，需要按照如下要求配置：
      If you use NixOS, add the `niri.nixosModules.niri` module and don't enable niri yet.
      Rebuild your system once to enable the binary cache, then enable niri.
      You can set `niri-flake.cache.enable = false;` to prevent this from happening.
      If you're not using the NixOS module, you can add the cache to your system by running `cachix use niri`.
      This works on any system with nix installed, not just NixOS.
    */
    programs.niri.enable = true;
    # nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri.package = pkgs.niri;
  };
}
