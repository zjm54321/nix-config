{ inputs, pkgs, systemFlakeHost, ... }:
let
  base = import ./base.nix;
  premission = import ./premission.nix;
  tui = import ./tui.nix;
  providers = import ./providers.nix;
  plugins = import ./plugins.nix;
  agents = import ./agents.nix;
  opencodeWithFeatures = pkgs.writeShellScriptBin "opencode" ''
    export OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true
    export OPENCODE_ENABLE_EXA=1
    exec ${pkgs.lib.getExe pkgs.opencode} "$@"
  '';
  agentsTemplate = pkgs.replaceVars ./AGENTS.md {
    inherit systemFlakeHost;
  };
  agentsInstructions = pkgs.runCommand "AGENTS.md" { } ''
    printf '%s\n\n' '# HERO Anti-OverDefense' > "$out"
    ${pkgs.gawk}/bin/awk '
      $0 == "## The block" {
        inSection = 1
        next
      }

      inSection && /^##[[:space:]]/ {
        exit 1
      }

      inSection && !inBlock && /^```[[:space:]]*$/ {
        inBlock = 1
        next
      }

      inBlock && /^```[[:space:]]*$/ {
        found = 1
        exit
      }

      inBlock {
        if (!hasFirstLine) {
          firstLine = $0
          hasFirstLine = 1
        }
        block = block $0 ORS
      }

      END {
        if (!found) {
          exit 1
        }
        if (firstLine != "=== SCOPE LIMITS (these bound what you PROPOSE, never what you look for) ===") {
          exit 1
        }
        if (index(block, "Say plainly when something is correct. Do not manufacture findings.") == 0) {
          exit 1
        }
        printf "%s", block
      }
    ' "${inputs.hero-anti-overdefense}/RULES.md" >> "$out"
    printf '\n' >> "$out"
    ${pkgs.coreutils}/bin/cat "${agentsTemplate}" >> "$out"
  '';
in
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencodeWithFeatures;
    inherit tui;
    agents.raw = ./raw.md;
    settings = base // {
      agent = agents;
      permission = premission;
      plugin = plugins;
      provider = providers;
    };
  };

  xdg.configFile."opencode/oh-my-opencode-slim.json".source = ./oh-my-opencode-slim.json;
  xdg.configFile."opencode/AGENTS.md".source = agentsInstructions;
}
