inputs:
{ pkgs, ... }:
let
  source = input: subdir: {
    path = input;
    inherit subdir;
    filter.maxDepth = 1;
  };

  shuorenhuaSkill = pkgs.runCommand "shuorenhua-v2.6.0" { } ''
    mkdir -p "$out"
    cp "${inputs.shuorenhua}/SKILL.md" "$out/SKILL.md"
    cp -r "${inputs.shuorenhua}/references" "$out/references"
    cp "${inputs.shuorenhua}/LICENSE" "$out/LICENSE"
  '';

  imageGenSkill = pkgs.runCommand "image-generation" { } ''
    mkdir -p "$out"
    cp -r ${./image-generation}/* "$out/"
  '';
in
{
  programs.agent-skills = {
    sources = {
      domain-modeling = source inputs.mattpocock-skills "skills/engineering/domain-modeling";
      grill-with-docs = source inputs.mattpocock-skills "skills/engineering/grill-with-docs";
      setup-matt-pocock-skills = source inputs.mattpocock-skills "skills/engineering/setup-matt-pocock-skills";
      grill-me = source inputs.mattpocock-skills "skills/productivity/grill-me";
      grilling = source inputs.mattpocock-skills "skills/productivity/grilling";

      commit-work = source inputs.agent-toolkit "skills/commit-work";
      ui-ux-pro-max = source inputs.ui-ux-pro-max-skill ".claude/skills/ui-ux-pro-max";
      make-interfaces-feel-better = source inputs.make-interfaces-feel-better "skills/make-interfaces-feel-better";
      better-icons = source inputs.better-icons "skills";
      web-perf = source inputs.cloudflare-skills "skills/web-perf";

      secretary-skills = source inputs.secretary-skills "skills";
      shuorenhua = source shuorenhuaSkill ".";
      image-generation = source imageGenSkill ".";
    };

    skills = {
      enable = [
        "domain-modeling"
        "grill-with-docs"
        "setup-matt-pocock-skills"
        "grill-me"
        "grilling"

        "commit-work"
        "ui-ux-pro-max"
        "make-interfaces-feel-better"
        "better-icons"
        "web-perf"

        "shuorenhua"
        "output-presentation"
        "image-generation"
      ];
      enableAll = false;
    };
  };
}
