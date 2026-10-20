{
  inputs,
  skills-catalog,
  secret,
  ...
}:
{
  imports = [
    ../../module/core
    ../../module/wsl
  ];

  networking.hostName = "136kf";

  home-manager = {
    extraSpecialArgs = {
      inherit inputs secret;
    };
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
