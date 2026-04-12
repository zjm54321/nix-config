{ inputs, ... }:
{
  imports = [
    inputs.mcp-servers-nix.homeManagerModules.default
    ./mcp.nix
    ./aichat.nix
  ];

  programs.mcp.enable = true;
}
