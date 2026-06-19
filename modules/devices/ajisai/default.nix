{ self, nixpkgs-20260616, ... }:
let
  device = self.lib.defineDevice {
    system = "x86_64-linux";
  };
in
  {
    nixosConfigurations."nenw-ajisai" = nixpkgs-20260616.lib.nixosSystem {
      inherit (device) system specialArgs;
      modules = [
        device.base
        ./hardware.nix
        ./packages.nix
        ./services.nix
        ./settings.nix
      ];
    };
  }

