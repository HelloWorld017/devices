{
	description = "nenw's Flake";

	inputs = {
		# Core Inputs
		nixpkgs = {
			url = "github:nixos/nixpkgs/nixpkgs-unstable";
		};

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
	};

	outputs = { ... }@inputs:
		(import ./modules/devices) inputs;
}
