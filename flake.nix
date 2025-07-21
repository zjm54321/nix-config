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

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-server.url = "github:nix-community/nixos-vscode-server";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # 由于 librime 版本问题，锁定 oh-my-rime 非万象词库版本
    # https://www.mintimate.cc/zh/guide/faQ.html#linux%E8%96%84%E8%8D%B7%E9%85%8D%E7%BD%AE%E6%97%A0%E6%B3%95%E4%BD%BF%E7%94%A8
    rime-config.url = "github:Mintimate/oh-my-rime/?rev=de1fa23fadcdad3c6ecd05ead3dfb1f756916fcb";
    my-rime-config.url = "git+ssh://git@github.com/zjm54321/my-rime-config.git";
    rime-config.flake = false;
    my-rime-config.flake = false;

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix/release-25.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    nur-personal.url = "github:zjm54321/NUR";
    nur-personal.inputs.nixpkgs.follows = "nixpkgs";

    mysecrets.url = "git+ssh://git@github.com/zjm54321/secrets.git";
    mysecrets.flake = false;
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
          specialArgs = {
            inherit
              inputs
              hostname
              vars
              secret
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
