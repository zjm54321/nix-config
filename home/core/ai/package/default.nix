{ pkgs, ... }:
{
  # AI companion package aggregator for agents, MCP servers, and Skills.
  home.packages = with pkgs; [
    gh
    google-chrome
    nixd
  ];
}
