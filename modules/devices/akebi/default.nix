{ nixpkgs-20251020, ... } @inputs:
let
	device = (import ../utils.nix).defineDevice {
		inherit inputs;
		system = "x86_64-linux";
	};
in
	{
		nixosConfigurations."nenw-akebi" = nixpkgs-20251020.lib.nixosSystem {
			inherit (device) system specialArgs;
			modules = [
				device.base
				./packages.nix
				./settings.nix
			];
		};
	}
