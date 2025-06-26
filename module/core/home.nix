{
  hostname,
  inputs,
  specialArgs,
  vars,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = inputs // specialArgs;
  home-manager.users.${vars.username} = import ../../host/${hostname}/home.nix;
}
