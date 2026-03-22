{ inputs, ... }:
{
  imports = [
    inputs.mcp-servers-nix.homeManagerModules.default
    ./mcp.nix
  ];

  programs.mcp.enable = true;
}
