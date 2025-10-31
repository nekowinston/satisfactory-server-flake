let
  lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.steam-fetcher.locked;
  steam-fetcher = import (fetchTarball {
    url = "https://github.com/${lock.owner}/${lock.repo}/archive/${lock.rev}.tar.gz";
    sha256 = lock.narHash;
  });
  pkgs = import <nixpkgs> {
    config = { };
    overlays = [ steam-fetcher ];
  };
in
pkgs.callPackage ./pkgs/satisfactory-server { }
