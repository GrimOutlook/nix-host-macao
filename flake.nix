{
  inputs = {
    nix-config.url = "github:GrimOutlook/nix-config";
    nixpkgs.follows = "nix-config/nixpkgs";
  };

  outputs =
    inputs@{
      nix-config,
      ...
    }:
    nix-config.lib.mkHost {
      hostname = "macao";
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = builtins.map (f: ./modules + "/${f}") (
        builtins.filter (f: builtins.match ".*\\.nix" f != null) (
          builtins.attrNames (builtins.readDir ./modules)
        )
      );
    };
}
