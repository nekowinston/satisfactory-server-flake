{
  description = "NixOS module for the Satisfactory dedicated server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    steam-fetcher = {
      url = "github:nix-community/steam-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      steam-fetcher,
    }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            steam-fetcher.overlays.default
            self.overlays.default
          ];
        };
    in
    {
      formatter = forAllSystems (system: (pkgsFor system).nixfmt-rfc-style);

      nixosModules = {
        satisfactory = import ./modules/satisfactory.nix { inherit self steam-fetcher; };
        default = self.nixosModules.satisfactory;
      };

      overlays.default = final: prev: {
        satisfactory-server = (final.callPackage ./pkgs/satisfactory-server { }).fhs;
        satisfactory-server-unwrapped = final.callPackage ./pkgs/satisfactory-server { };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          version = self.shortRev or self.dirtyShortRev;
          mkOptionDoc = args: (pkgs.callPackage ./pkgs/docs.nix { }) (args // { inherit version; });
        in
        {
          inherit (pkgs) satisfactory-server satisfactory-server-unwrapped;
          default = pkgs.satisfactory-server;
          docs = mkOptionDoc { modules = [ self.nixosModules.satisfactory ]; };
        }
      );
    };
}
