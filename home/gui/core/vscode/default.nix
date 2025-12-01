{
  pkgs,
  lib,
  nix-vscode-extensions,
  ...
}:
{
  programs.vscode = {
    package =
      (pkgs.vscodium.override {
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
          # 使其在Gtk4下使用GTK_IM_MODULE，这样fcitx5就能正常工作
          # (目前只有chromium/chrome支持，electron还不支持)
          "--gtk-version=4"
          # 使用text-input-v3
          "--enable-wayland-ime"
          "--wayland-text-input-version=3"
          "--password-store=\"gnome-libsecret\""
        ];
      }).overrideAttrs # 修复 copilot 扩展无法正常工作的 bug
        (oldAttrs: {
          postPatch = (oldAttrs.postPatch or "") + ''
            if [ -f resources/app/product.json ]; then
              tmp="$(mktemp)"
              ${pkgs.jq}/bin/jq '.trustedExtensionAuthAccess = [
                "GitHub.copilot",
                "GitHub.copilot-nightly",
                "GitHub.copilot-chat"
              ]' resources/app/product.json > "$tmp" && mv "$tmp" resources/app/product.json || true
            fi
          '';
        });
    profiles.default.extensions = import ./extensions.nix { inherit nix-vscode-extensions pkgs; };
    profiles.default.userSettings = lib.mkForce (pkgs.lib.importJSON ./settings.json);
  };
  programs.neovim.enable = true; # 让vscode的neovim插件工作

  home.shellAliases.code = "codium";
}
