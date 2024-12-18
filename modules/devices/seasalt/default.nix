{ self, nixpkgs, home-manager, ... } @inputs:
{
	nixosConfigurations."nenw-seasalt" = nixpkgs.lib.nixosSystem {
		system = "aarch64-linux";
		specialArgs = { inherit self inputs; };
		modules = let
			base = import ../../base;
			pkgs = import ../../packages;
		in
			[
				base
				pkgs.nvim
				pkgs.git
				pkgs.zsh
				home-manager.nixosModules.home-manager
			];
	};
}
