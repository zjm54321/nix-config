{
  inputs,
  vars,
  ...
}:
{
  imports = [ inputs.nixos-wsl.nixosModules.default ];
  system.stateVersion = "25.05";
  wsl.enable = true;
  wsl.defaultUser = vars.username;
}
