inputs:
{ pkgs, ... }:
let
  source = input: subdir: {
    path = input;
    inherit subdir;
    filter.maxDepth = 1;
  };

  zhihuSkill =
    pkgs.runCommand "zhihu-cli-skill-0.3.0"
      {
        src = pkgs.fetchurl {
          url = "https://developer-cdn.zhihu.com/zhihu-cli/releases/stable/skill/0.3.0/zhihu-cli-skill-0.3.0.zip";
          hash = "sha256-KvJkfEaKNmBQo53Xi42ETsyutnnZGlbNE0VzwLOD5N8=";
        };
      }
      ''
        mkdir -p "$out"
        ${pkgs.unzip}/bin/unzip "$src" -d "$out"
      '';

  shuorenhuaSkill = pkgs.runCommand "shuorenhua-v2.4.0" { } ''
    mkdir -p "$out"
    cp "${inputs.shuorenhua}/SKILL.md" "$out/SKILL.md"
    cp -r "${inputs.shuorenhua}/references" "$out/references"
    cp "${inputs.shuorenhua}/LICENSE" "$out/LICENSE"
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

      git-commit = source inputs.awesome-copilot "skills/git-commit";
      xiaohongshu-cli = source inputs.xiaohongshu-cli ".";
      ui-ux-pro-max = source inputs.ui-ux-pro-max-skill ".claude/skills/ui-ux-pro-max";
      make-interfaces-feel-better = source inputs.make-interfaces-feel-better "skills/make-interfaces-feel-better";
      better-icons = source inputs.better-icons "skills";
      web-perf = source inputs.cloudflare-skills "skills/web-perf";
      zhihu = {
        path = zhihuSkill;
        subdir = "zhihu";
        filter.maxDepth = 1;
      };

      secretary-skills = source inputs.secretary-skills "skills";
      shuorenhua = source shuorenhuaSkill ".";
    };

    skills = {
      enable = [
        "domain-modeling"
        "grill-with-docs"
        "setup-matt-pocock-skills"
        "grill-me"
        "grilling"

        "git-commit"
        "xiaohongshu-cli"
        "ui-ux-pro-max"
        "make-interfaces-feel-better"
        "better-icons"
        "web-perf"
        "zhihu"

        "shuorenhua"
        "output-presentation"
      ];
      enableAll = false;
    };
  };
}
