{
  inputs = {
    agent-skills.url = "github:Kyure-A/agent-skills-nix";

    oh-my-opencode-slim = {
      url = "github:alvinunreal/oh-my-opencode-slim";
      flake = false;
    };

    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };

    officecli = {
      url = "github:iOfficeAI/OfficeCLI";
      flake = false;
    };

    awesome-copilot = {
      url = "github:github/awesome-copilot";
      flake = false;
    };

    xiaohongshu-cli = {
      url = "github:jackwener/xiaohongshu-cli";
      flake = false;
    };

    ui-ux-pro-max-skill = {
      url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
      flake = false;
    };

    make-interfaces-feel-better = {
      url = "github:jakubkrehel/make-interfaces-feel-better";
      flake = false;
    };

    better-icons = {
      url = "github:better-auth/better-icons";
      flake = false;
    };

    cloudflare-skills = {
      url = "github:cloudflare/skills";
      flake = false;
    };

    secretary-skills = {
      url = "github:zjm54321/secretary-skills";
      flake = false;
    };
  };

  outputs = inputs: {
    homeManagerModules.default = {
      imports = [
        inputs.agent-skills.homeManagerModules.default
        (import ./home-manager.nix inputs)
      ];
    };
  };
}
