{
  pkgs,
  vars,
  lib,
  config,

  ...
}:
{
  ###################################################################################
  #
  #  虚拟化 - Libvirt(QEMU/KVM) / Docker / LXD / WayDroid
  #
  ###################################################################################

  /*
    启用嵌套虚拟化，安全容器和嵌套虚拟机需要此功能。
    应在每台主机的 /hosts 中单独设置，而不是在这里统一设置。

    对于 AMD CPU，请在 kernelModules 中添加 "kvm-amd"。
    ```nix
    boot.kernelModules = ["kvm-amd"];
    boot.extraModprobeConfig = "options kvm_amd nested=1";  # 针对 amd cpu
    ```

    对于 Intel CPU，请在 kernelModules 中添加 "kvm-intel"。
    ```nix
    boot.kernelModules = ["kvm-intel"];
    boot.extraModprobeConfig = "options kvm_intel nested=1"; # 针对 intel cpu
    ```
  */

  options = {
    podman.enable = lib.mkEnableOption "Podman container engine";
    kvm.enable = lib.mkEnableOption "KVM nested virtualization support";
  };

  config = lib.mkMerge [
    (lib.mkIf config.kvm.enable {
      boot.kernelModules = [ "vfio-pci" ];
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            # 将此选项设为 false 可能导致已有虚拟机的文件权限问题。
            # 如遇此问题，请手动将 /var/lib/libvirt/qemu 下相关文件的所有权改为 qemu-libvirtd。
            runAsRoot = true;
            swtpm.enable = true;
          };
        };
      };
      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = [ vars.username ];
      virtualisation.spiceUSBRedirection.enable = true;
    })
    (lib.mkIf config.podman.enable {
      virtualisation = {
        docker.enable = false;
        podman = {
          enable = true;
          # 为 podman 创建 `docker` 别名，可作为 docker 的直接替代品使用
          dockerCompat = true;
          # 让 podman-compose 下的容器可以互相通信所需
          defaultNetwork.settings.dns_enabled = true;
          # 定期清理 Podman 资源
          autoPrune = {
            enable = true;
            dates = "weekly";
            flags = [ "--all" ];
          };
        };
        oci-containers.backend = "podman";

        # 用法参考：https://wiki.nixos.org/wiki/Waydroid
        # waydroid.enable = true;

        # lxd.enable = true;
      };
    })
  ];
}
