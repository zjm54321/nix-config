{
  imports = [
    ../../module/core
    ../../module/wsl
  ];

  networking.hostName = "nix";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ming = import ./home.nix;
  };

  system.stateVersion = "26.05";
}
