{ self, nixpkgs, home-manager, ... } @inputs:
let
	system = "aarch64-linux";
	base = import "${self}/modules/base";
	pkgs = import "${self}/modules/packages";
in {
	nixosConfigurations."nenw-seasalt" = nixpkgs.lib.nixosSystem {
		inherit system;
		specialArgs = { inherit self inputs system; };
		modules = [
			base
			pkgs.nvim
			pkgs.git
			pkgs.zsh
			home-manager.nixosModules.home-manager
		];
	};
}
