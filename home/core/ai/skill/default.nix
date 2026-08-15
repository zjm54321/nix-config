{
  programs.agent-skills = {
    enable = true;

    targets.agents = {
      enable = true;
      structure = "symlink-tree";
    };
  };
}
