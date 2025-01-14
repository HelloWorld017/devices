{ self, nixpkgs, nixpkgs-rolling, home-manager, ... } @inputs:
let
	system = "x86_64-linux";
	base = import "${self}/modules/base";
	devicePkgs = import ./packages;
	rollingPkgs = nixpkgs-rolling.legacyPackages.${system};
in
	{
		nixosConfigurations."nenw-yanamianna" = nixpkgs.lib.nixosSystem {
			inherit system;
			specialArgs = { inherit self inputs system rollingPkgs; };
			modules = [
				base
				devicePkgs.preset-default
				devicePkgs.preset-server
				home-manager.nixosModules.home-manager
			];
		};
	}
