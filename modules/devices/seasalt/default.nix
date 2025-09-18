{ nixpkgs, ... } @inputs:
let
	device = (import ../utils.nix).defineDevice {
		inherit inputs;
		system = "aarch64-linux";
	};
in {
	nixosConfigurations."nenw-seasalt" = nixpkgs.lib.nixosSystem {
		inherit (device) system specialArgs;
		modules = with device; [
			base
			repo.nvim
			repo.git
			repo.zsh
			home-manager.nixosModules.home-manager
		];
	};
}
