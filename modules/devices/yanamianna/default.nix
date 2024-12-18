{ self, nixpkgs, home-manager, ... } @inputs:
let
	base = import "${self}/modules/base";
	devicePkgs = import ./packages;
in
	{
		nixosConfigurations."nenw-yanamianna" = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			specialArgs = { inherit self inputs; };
			modules = [
				base
				devicePkgs.preset-default
				home-manager.nixosModules.home-manager
			];
		};
	}
