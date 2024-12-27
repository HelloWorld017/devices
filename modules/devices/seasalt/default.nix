{ self, nixpkgs, home-manager, ... } @inputs:
let
	base = import "${self}/modules/base";
	pkgs = import "${self}/modules/packages";
	utils = import "${self}/utils";
in {
	nixosConfigurations."nenw-seasalt" = nixpkgs.lib.nixosSystem {
		system = "aarch64-linux";
		specialArgs = { inherit self inputs utils; };
		modules = [
			base
			pkgs.nvim
			pkgs.git
			pkgs.zsh
			home-manager.nixosModules.home-manager
		];
	};
}
