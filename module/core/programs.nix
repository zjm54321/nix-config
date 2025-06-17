{
  pkgs,
  ...
}:
{

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    nushell
    just
    git
    git-lfs

    wget
    curl

    # 压缩工具
    zip
    xz
    zstd
    unzipNLS
    p7zip

    fastfetch
  ];
}
