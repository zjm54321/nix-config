{ skills-catalog, ... }:
{
  imports = [
    ../../module/core
    ../../module/wsl
  ];

  networking.hostName = "nix";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ming = {
      imports = [
        ./home.nix
        skills-catalog.homeManagerModules.default
      ];
    };
  };

  system.stateVersion = "26.05";
}
