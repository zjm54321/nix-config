{
  description = "Minimal terminal-only NixOS-WSL configuration for 136kf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 只给 codex 用：nixos-unstable f4a03c0 的 codex 0.167.0 构建失败（缺系统库输入），
    # master 16b463698 已修复且有官方缓存。固定到这个提交；nixos-unstable 包含该修复后删除。
    nixpkgs-codex.url = "github:NixOS/nixpkgs/7f19607d4bb849da1dcc4282c626a983144db476";

    # The integrated package owns plugins, skills and MCP defaults.
    opencode-qol.url = "github:zjm54321/opencode-qol/v2.2.5-qol.2";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    skills-catalog.url = "path:./module/ai/skill";

    mysecrets = {
      url = "github:zjm54321/secrets";
      flake = false;
    };

    hero-anti-overdefense = {
      url = "github:wanshuiyin/HERO-Anti-OverDefense";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      skills-catalog,
      mysecrets,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      secret = import "${mysecrets}/secret.nix";
    in
    {
      nixosConfigurations."136kf" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs
            self
            skills-catalog
            secret
            ;
        };
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          ./host/136kf
        ];
      };

      formatter.${system} = pkgs.nixfmt-tree;

      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.just ];
      };
    };
}
