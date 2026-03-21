{
  inputs,
  pkgs,
  ...
}:
let
  taskwarrior-mcp =
    inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.zjm54321.taskwarrior-mcp;
in
{
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = {
      weekstart = "Monday";
      default.command = "next";
      color = true;
    };
  };

  home.packages = with pkgs; [ taskwarrior-tui ];

  programs.mcp.servers.taskwarrior = {
    command = "${taskwarrior-mcp}/bin/taskwarrior-mcp";
  };
}
