{ inputs, pkgs, ... }:
let
  # Evaluate NUR against the configured package set so local compatibility
  # overlays apply to dependencies of NUR packages as well.
  nurPackages = (pkgs.extend inputs.nur.overlays.default).nur.repos.zjm54321;
  zhihuCli = pkgs.callPackage ../../../../module/ai/skill/packages/zhihu-cli.nix { };
in
{
  # AI companion package aggregator for agents, MCP servers, and Skills.
  home.packages = with pkgs; [
    gh
    google-chrome
    nixd
    zhihuCli
    nurPackages.xiaohongshu-cli
  ];
}
