{ darwin, home-manager, ... }: {
	darwinConfigurations."nenw-iceflake" = darwin.lib.darwinSystem {
		system = "aarch64-darwin";
		modules = let
			base = import ../../base;
			pkgs = import ../../packages;
			devicePkgs = import ./packages;
		in
			[home-manager.darwinModules.home-manager] ++
			base ++
			devicePkgs.preset-default ++
			devicePkgs.preset-work ++
			[
				pkgs.alacritty
				pkgs.fonts
				pkgs.git
				pkgs.karabiner
				pkgs.kitty
				pkgs.nvim
				pkgs.tmux
				pkgs.zsh
			];
	};
}
