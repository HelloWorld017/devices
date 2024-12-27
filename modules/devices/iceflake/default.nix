{ self, darwin, home-manager, ... } @inputs:
let
	system = "aarch64-darwin";
	base = import "${self}/modules/base";
	pkgs = import "${self}/modules/packages";
	utils = import "${self}/utils";
	devicePkgs = import ./packages;
in
	{
		darwinConfigurations."nenw-iceflake" = darwin.lib.darwinSystem {
			inherit system;
			specialArgs = { inherit self inputs utils system; };
			modules = [
				base
				devicePkgs.preset-default
				devicePkgs.preset-work
				pkgs.alacritty
				pkgs.fonts
				pkgs.git
				pkgs.karabiner
				pkgs.kitty
				pkgs.nvim
				pkgs.tmux
				pkgs.zsh
				home-manager.darwinModules.home-manager
			];
		};
	}
