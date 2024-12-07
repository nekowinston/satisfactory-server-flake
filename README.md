# Satisfactory Dedicated Server for NixOS

## Usage

Add the flake to your flake inputs:

```nix
{
  inputs = {
    satisfactory-server = {
      url = "github:nekowinston/satisfactory-server-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.steam-fetcher.follows = "steam-fetcher";
    };
  };
}
```

Add the module to your NixOS config:
```nix
{
  nixosConfigurations.cambrian = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.satisfactory-server.nixosModules.default
    ];
  };
}
```

You can then configure it like:

```nix
{
  services.satisfactory = {
    enable = true;
    openFirewall = true;
  };
}

```

For more options, see [`./docs/nixos-options.md`](./docs/nixos-options.md).

## Updates

I appreciate version bump PRs!\
If you want to help out, here's a brief guide:

1. Visit this [SteamDB page](https://steamdb.info/depot/1690802/history/),
   and make note of both the latest **Manifest ID**, and the **Build ID**.

2. Edit [`./pkgs/Satisfactory-server/default.nix`](./pkgs/Satisfactory-server/default.nix):

   - set `version` to the **Build ID**
   - set `src.manifest` to the **Manifest ID**
   - set `src.hash` to `""`

3. To fetch the hash for the latest version, run:
   ```command
   NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#packages.x86_64-linux.default`
   ```

4. The build will error out, warning about a mismatched hash; update `src.hash` to the new hash.

5. Commit & open a PR.
