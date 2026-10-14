inputs:
{ pkgs, ... }:
let
  source = input: subdir: {
    path = input;
    inherit subdir;
    filter.maxDepth = 1;
  };

  zhihuCli = pkgs.callPackage ./packages/zhihu-cli.nix { };

  zhihuSkill =
    pkgs.runCommand "zhihu-cli-skill-0.7.3"
      {
        src = pkgs.fetchurl {
          url = "https://developer-cdn.zhihu.com/zhihu-cli/releases/stable/skill/0.7.3/zhihu-cli-skill-0.7.3.zip";
          hash = "sha256-XvMaPY9BQhbm1b4FSkGdeLuxYJRxf65UXdDQhD2vQpw=";
        };
      }
      ''
        mkdir -p "$out"
        ${pkgs.unzip}/bin/unzip "$src" -d "$out"
        # Use the Nix-managed binary without moving writable CLI state into the store.
        substituteInPlace "$out/zhihu/scripts/run.sh" \
          --replace-fail 'BINARY="$CLI_HOME/current/zhihu-cli"' 'BINARY="${zhihuCli}/bin/zhihu-cli"'
      '';

  shuorenhuaSkill = pkgs.runCommand "shuorenhua-v2.5.1" { } ''
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
