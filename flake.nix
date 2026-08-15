{
  description = "Minimal terminal-only NixOS-WSL configuration for 136kf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    skills-catalog.url = "path:./skills";
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      skills-catalog,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations."136kf" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit skills-catalog; };
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          ./host/136kf
        ];
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
