{ self, nixpkgs-20261116, ... }:
let
  device = self.lib.defineDevice {
    system = "x86_64-linux";
  };
in
  {
    nixosConfigurations."nenw-akebi" = nixpkgs-20261116.lib.nixosSystem {
      inherit (device) system specialArgs;
      modules = [
        device.base
        ./packages.nix
        ./services.nix
        ./settings.nix
      ];
    };
  }
