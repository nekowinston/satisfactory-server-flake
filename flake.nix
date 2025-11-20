{
  description = "NixOS module for the Satisfactory dedicated server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    steam-fetcher = {
      url = "github:nix-community/steam-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:nixos/flake-compat";
  };

  outputs =
    { self, steam-fetcher, ... }@inputs:
    let
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
        };
        overlays = [
          steam-fetcher.overlay
          self.overlays.default
        ];
      };
      modules = [ self.nixosModules.satisfactory ];
      version = self.shortRev or self.dirtyShortRev;
    in
    {
      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;

      nixosModules = {
        satisfactory = import ./modules/satisfactory.nix {
          inherit self steam-fetcher;
        };
        default = self.nixosModules.satisfactory;
      };

      overlays.default = final: prev: {
        satisfactory-server = final.satisfactory-server-unwrapped.fhs;
        satisfactory-server-unwrapped = final.callPackage ./pkgs/satisfactory-server { };
      };

      packages.x86_64-linux = {
        default = pkgs.satisfactory-server;

        docs = pkgs.callPackage ./pkgs/docs.nix {
          inherit modules version;
        };

        tests.satisfactory-server = pkgs.callPackage ./tests/nixos.nix {
          inherit modules;
        };

        inherit (pkgs) satisfactory-server satisfactory-server-unwrapped;
      };
    };
}
