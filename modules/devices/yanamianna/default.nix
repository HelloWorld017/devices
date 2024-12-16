{ nixpkgs, home-manager, ... }: {
	nixosConfigurations."nenw-yanamianna" = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
		modules = let
			base = import ../../base;
			pkgs = import ../../packages;
			devicePkgs = import ./packages;
		in
			[home-manager.nixosModules.home-manager] ++
			base ++
			devicePkgs.preset-default ++
			[
				pkgs.fonts
				pkgs.git
				pkgs.nvim
				pkgs.tmux
				pkgs.zsh
			];
	};
}
