{ darwin, home-manager, ... } @inputs:
let
	device = (import ../utils.nix).defineDevice {
		inherit inputs;
		system = "aarch64-darwin";
	};

	deviceRepo = import ./packages;
in
	{
		darwinConfigurations."nenw-iceflake" = darwin.lib.darwinSystem {
			inherit (device) system specialArgs;
			modules = with device; [
				base
				deviceRepo.preset-default
				deviceRepo.preset-work
				repo.alacritty
				repo.fonts
				repo.git
				repo.karabiner
				repo.kitty
				repo.nvim
				repo.tmux
				repo.zsh
				home-manager.darwinModules.home-manager
			];
		};
	}
