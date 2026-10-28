{ self, nixpkgs-20261028, ... }:
let
  device = self.lib.defineDevice {
    system = "x86_64-linux";
  };
in
  {
    nixosConfigurations."nenw-shigureui" = nixpkgs-20261028.lib.nixosSystem {
      inherit (device) system specialArgs;
      modules = [
        device.base
        ./hardware.nix
        ./packages.nix
        ./settings.nix
      ];
    };
  }
