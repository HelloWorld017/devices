{ self, nixpkgs-20261028, ... }:
let
  device = self.lib.defineDevice {
    system = "x86_64-linux";
  };
in
  {
    nixosConfigurations."nenw-akebi" = nixpkgs-20261028.lib.nixosSystem {
      inherit (device) system specialArgs;
      modules = [
        device.base
        ./packages.nix
        ./services.nix
        ./settings.nix
      ];
    };
  }
