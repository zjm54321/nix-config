{
  description = "zjm54321 的 NixOS 配置";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-server.url = "github:nix-community/nixos-vscode-server";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixos-wsl,
      flake-utils,
      ...
    }:
    {
      nixosConfigurations = {
        vm-hyperv =
          let
            vars = import ./vars;
            specialArgs = { inherit inputs vars; };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";

            modules = [
              ./host/vm-hyperv
              ./module

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = inputs // specialArgs;
                home-manager.users.${vars.username} = import ./host/vm-hyperv/home.nix;
              }
            ];
          };

        vm-wsl =
          let
            vars = import ./vars;
            specialArgs = { inherit inputs vars; };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";

            modules = [
              ./host/vm-wsl
              ./module

              nixos-wsl.nixosModules.default
              {
                system.stateVersion = "25.05";
                wsl.enable = true;
                wsl.defaultUser = vars.username;
              }
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = inputs // specialArgs;
                home-manager.users.${vars.username} = import ./host/vm-wsl/home.nix;
              }
            ];
          };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt-rfc-style
            nil
          ];
        };
      }
    );
}
