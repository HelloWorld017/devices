{
	description = "nenw's Flake";

	inputs = {
		# Core Inputs
		nixpkgs = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Other Inputs
		anyrun = {
			url = "github:anyrun-org/anyrun";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		ghostty = { url = "github:ghostty-org/ghostty"; };
		hyprswitch = {
			url = "github:h3rmt/hyprswitch/release";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nnf = { url = "github:thelegy/nixos-nftables-firewall"; };
	};

	outputs = { ... }@inputs:
		(import ./modules/devices) inputs;
}
