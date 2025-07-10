{ pkgs, ... }:
{
  # FHS 环境，用于支持 flatpak、appImage 等
  environment.systemPackages = [
    # 通过 `fhs` 命令创建 FHS 环境，这样我们就可以在 NixOS 中运行非 NixOS 软件包！
    (
      let
        base = pkgs.appimageTools.defaultFhsEnvArgs;
      in
      pkgs.buildFHSEnv (
        base
        // {
          name = "fhs";
          targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [ pkgs.pkg-config ];
          profile = "export FHS=1";
          runScript = "bash";
          extraOutputsToInstall = [ "dev" ];
        }
      )
    )
  ];

  programs.appimage.enable = true;

  /*
    https://github.com/Mic92/nix-ld

    nix-ld 会将自己安装在 `/lib64/ld-linux-x86-64.so.2`，
    这样它就可以作为非 NixOS 二进制文件的动态链接器。

    nix-ld 就像一个中间件，位于实际的链接加载器（位于 `/nix/store/.../ld-linux-x86-64.so.2`）
    和非 NixOS 二进制文件之间。它会：

      1. 读取 `NIX_LD` 环境变量并使用它来找到实际的链接加载器。
      2. 读取 `NIX_LD_LIBRARY_PATH` 环境变量并使用它来为实际的链接加载器
         设置 `LD_LIBRARY_PATH` 环境变量。

    nix-ld 的 NixOS 模块会为 `NIX_LD` 和 `NIX_LD_LIBRARY_PATH` 环境变量设置默认值，
    所以它可以开箱即用：

     - https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/programs/nix-ld.nix#L37-L40

    你可以在运行非 NixOS 二进制文件的环境中覆盖 `NIX_LD_LIBRARY_PATH`
    来自定义共享库的搜索路径。
  */
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };
}
