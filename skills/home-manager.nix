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
in
{
  programs.agent-skills = {
    sources = {
      oh-my-opencode-slim = source inputs.oh-my-opencode-slim "src/skills";

      domain-modeling = source inputs.mattpocock-skills "skills/engineering/domain-modeling";
      grill-with-docs = source inputs.mattpocock-skills "skills/engineering/grill-with-docs";
      setup-matt-pocock-skills = source inputs.mattpocock-skills "skills/engineering/setup-matt-pocock-skills";
      grill-me = source inputs.mattpocock-skills "skills/productivity/grill-me";
      grilling = source inputs.mattpocock-skills "skills/productivity/grilling";

      officecli = source inputs.officecli ".";
      morph-ppt = source inputs.officecli "skills/morph-ppt";
      morph-ppt-3d = source inputs.officecli "skills/morph-ppt-3d";
      officecli-academic-paper = source inputs.officecli "skills/officecli-academic-paper";
      officecli-data-dashboard = source inputs.officecli "skills/officecli-data-dashboard";
      officecli-docx = source inputs.officecli "skills/officecli-docx";
      officecli-financial-model = source inputs.officecli "skills/officecli-financial-model";
      officecli-pitch-deck = source inputs.officecli "skills/officecli-pitch-deck";
      officecli-pptx = source inputs.officecli "skills/officecli-pptx";
      officecli-word-form = source inputs.officecli "skills/officecli-word-form";
      officecli-xlsx = source inputs.officecli "skills/officecli-xlsx";

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
    };

    skills = {
      enable = [
        "simplify"
        "codemap"
        "clonedeps"
        "deepwork"
        "reflect"
        "oh-my-opencode-slim"
        "worktrees"
        "verification-planning"

        "domain-modeling"
        "grill-with-docs"
        "setup-matt-pocock-skills"
        "grill-me"
        "grilling"

        "officecli"
        "morph-ppt"
        "morph-ppt-3d"
        "officecli-academic-paper"
        "officecli-data-dashboard"
        "officecli-docx"
        "officecli-financial-model"
        "officecli-pitch-deck"
        "officecli-pptx"
        "officecli-word-form"
        "officecli-xlsx"

        "git-commit"
        "xiaohongshu-cli"
        "ui-ux-pro-max"
        "make-interfaces-feel-better"
        "better-icons"
        "web-perf"
        "zhihu"

        "secretary-humanizer"
        "output-presentation"
      ];
      enableAll = false;
    };
  };
}
