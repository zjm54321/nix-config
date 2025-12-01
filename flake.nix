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
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-server.url = "github:nix-community/nixos-vscode-server";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    rime-config.url = "github:Mintimate/oh-my-rime/";
    my-rime-config.url = "git+ssh://git@github.com/zjm54321/my-rime-config.git";
    rime-config.flake = false;
    my-rime-config.flake = false;

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # [fixme] lanzaboote 0.4.3 不支持
    lanzaboote.url = "github:nix-community/lanzaboote/";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix/release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    anyrun.url = "github:anyrun-org/anyrun";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    mysecrets.url = "git+ssh://git@github.com/zjm54321/secrets.git";
    mysecrets.flake = false;

    harmonia.url = "github:nix-community/harmonia";
    harmonia.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      mysecrets,
      ...
    }:
    let
      mknixosConfigurations =
        hostname:
        let
          vars = import ./vars;
          secret = import "${mysecrets}/secret.nix";
          system = "x86_64-linux";
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          specialArgs = {
            inherit
              inputs
              hostname
              vars
              secret
              pkgs-unstable
              ;
          };
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
        e2 = mknixosConfigurations "e2";
        home-server = mknixosConfigurations "home-server";
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
            just
            nushell
          ];
        };
      }
    );
}
