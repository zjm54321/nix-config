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

    # rime 配置
    rime-config.url = "github:Mintimate/oh-my-rime/main";
    my-rime-config.url = "git+ssh://git@github.com/zjm54321/my-rime-config.git";
    rime-config.flake = false;
    my-rime-config.flake = false;
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      mknixosConfigurations =
        hostname:
        let
          vars = import ./vars;
          system = "x86_64-linux";
          specialArgs = { inherit inputs hostname vars; };
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [ ./module ];
        };
    in
    {
      nixosConfigurations = {
        vm-hyperv = mknixosConfigurations "vm-hyperv";
        vm-wsl = mknixosConfigurations "vm-wsl";
        sgo3 = mknixosConfigurations "sgo3";
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
