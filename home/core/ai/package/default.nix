{ inputs, pkgs, ... }:
let
  nurPackages = inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.zjm54321;
in
{
  # AI companion package aggregator for agents, MCP servers, and Skills.
  home.packages = with pkgs; [
    gh
    google-chrome
    nixd
    nurPackages.officecli
    nurPackages.zhihu-cli
    nurPackages.xiaohongshu-cli
  ];
}
