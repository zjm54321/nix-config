{
  services.lvm.boot.thin.enable = true;

  boot.initrd.kernelModules = [
    "dm-raid"
    "raid0"
    "dm-cache-default"
  ];

  fileSystems."/data" = {
    device = "/dev/mapper/hybrid-data";
    fsType = "ext4";
    options = [ "nofail" ];
  };

}
