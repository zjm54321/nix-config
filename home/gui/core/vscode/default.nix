{
  pkgs,
  nix-vscode-extensions,
  ...
}:
{

  programs.vscode = {
    package = pkgs.vscodium.override {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        # 使其在Gtk4下使用GTK_IM_MODULE，这样fcitx5就能正常工作
        # (目前只有chromium/chrome支持，electron还不支持)
        "--gtk-version=4"
        # 使用text-input-v3
        "--enable-wayland-ime"
        "--wayland-text-input-version=3"
      ];
    };
    profiles.default.extensions = import ./extensions.nix {
      inherit nix-vscode-extensions pkgs;
    };
    profiles.default.userSettings = pkgs.lib.importJSON ./settings.json;
  };
}
