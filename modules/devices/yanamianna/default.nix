{ nixpkgs-20251020, ... } @inputs:
let
	device = (import ../utils.nix).defineDevice {
		inherit inputs;
		system = "x86_64-linux";
	};
	deviceRepo = import ./packages;
in
	{
		nixosConfigurations."nenw-yanamianna" = nixpkgs-20251020.lib.nixosSystem {
			inherit (device) system specialArgs;
			modules = [
				device.base
				deviceRepo.preset-default
				deviceRepo.preset-server
			];
		};
	}
