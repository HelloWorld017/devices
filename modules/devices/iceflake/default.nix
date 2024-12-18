{ self, darwin, home-manager, ... } @inputs:
let
	base = import "${self}/modules/base";
	pkgs = import "${self}/modules/packages";
	devicePkgs = import ./packages;
in
	{
		darwinConfigurations."nenw-iceflake" = darwin.lib.darwinSystem {
			system = "aarch64-darwin";
			specialArgs = { inherit self inputs; };
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
