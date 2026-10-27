{
  inputs,
  ...
}:
{
  imports = [ inputs.opencode-qol.homeManagerModules.default ];

  programs.opencode-qol = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./opencode.json);
    slim.settings.preset = "default";
  };
}
