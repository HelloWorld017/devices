{ self, nixpkgs-20251020, ... }:
let
  device = self.lib.defineDevice {
    system = "aarch64-linux";
  };
in
  {
    nixosConfigurations."nenw-ruri" = nixpkgs-20251020.lib.nixosSystem {
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
