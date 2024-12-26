{ pkgs, lib, config, options, ... }:
{
	config = {
		# Nix Configuration
		nix.settings.substituters = [ "https://cache.nixos.org/" ];
		nix.settings.trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ]; 
		nix.settings.trusted-users = [ "@admin" ];
		nix.settings.experimental-features = ["nix-command" "flakes"];
		nix.settings.auto-optimise-store = true;

		nixpkgs.config.allowUnfree = true;
	}
	// (
		if options.nix ? "configureBuildUsers" then {
			nix.configureBuildUsers = true;
		} else {}
	)
	// (
		if options.services ? "nix-daemon" then {
			services.nix-daemon.enable = true;
		} else {}
	);
}
