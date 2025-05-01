{ nixpkgs, home-manager, wsl, ... } @inputs:
let
	device = (import ../utils.nix).defineDevice {
		inherit inputs;
		system = "x86_64-linux";
	};
	deviceRepo = import ./packages;
in
	{
		nixosConfigurations."nenw-akebi" = nixpkgs.lib.nixosSystem {
			inherit (device) system specialArgs;
			modules = [
				device.base
				deviceRepo.preset-default
				home-manager.nixosModules.home-manager
				wsl.nixosModules.default
			];
		};
	}
