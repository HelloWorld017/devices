{ nixpkgs, home-manager, ... } @inputs:
let
	device = (import ../utils.nix).defineDevice {
		inherit inputs;
		system = "x86_64-linux";
	};
	deviceRepo = import ./packages;
in
	{
		nixosConfigurations."nenw-yanamianna" = nixpkgs.lib.nixosSystem {
			inherit (device) system specialArgs;
			modules = [
				device.base
				deviceRepo.preset-default
				deviceRepo.preset-server
				home-manager.nixosModules.home-manager
			];
		};
	}
