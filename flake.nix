{
  inputs = {
    nix-config.url = "github:GrimOutlook/nix-config";
    nixpkgs.follows = "nix-config/nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-config,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations.macao = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          nix-config.nixosModules.default
        ]
        ++ builtins.map (f: ./modules + "/${f}") (
          builtins.filter (f: builtins.match ".*\\.nix" f != null) (
            builtins.attrNames (builtins.readDir ./modules)
          )
        );
      };
    };
}
