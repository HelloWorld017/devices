{ self, nixpkgs, home-manager, ... } @inputs:
let
	system = "x86_64-linux";
	base = import "${self}/modules/base";
	utils = import "${self}/utils";
	devicePkgs = import ./packages;
in
	{
		nixosConfigurations."nenw-yanamianna" = nixpkgs.lib.nixosSystem {
			inherit system;
			specialArgs = { inherit self inputs utils system; };
			modules = [
				base
				devicePkgs.preset-default
				home-manager.nixosModules.home-manager
			];
		};
	}
