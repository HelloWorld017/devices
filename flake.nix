{
	description = "nenw's Flake";

	inputs = {
		# Core Inputs
		nixpkgs-base = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
		nixpkgs-latest = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
		nixpkgs-20251020 = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixpkgs-base";
		};

		home-manager = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixpkgs-base";
		};

		agenix = {
			url ="github:ryantm/agenix";
			inputs.nixpkgs.follows = "nixpkgs-base";
		};

		agenix-template = { url = "github:jhillyerd/agenix-template/1.0.0"; };
		std = { url = "github:chessai/nix-std"; };
		wsl = { url = "github:nix-community/NixOS-WSL/main"; };

		# Other Inputs
		figma-linux = {
			url = "github:HelloWorld017/figma-linux-nixos";
			inputs.nixpkgs.follows = "nixpkgs-base";
		};

		midnightway = {
			url = "github:HelloWorld017/midnightway";
			inputs.nixpkgs.follows = "nixpkgs-base";
		};

		notion-linux = {
			url = "github:HelloWorld017/notion-linux-nixos";
			inputs.nixpkgs.follows = "nixpkgs-base";
		};

		rose-pine-hyprcursor = {
			url = "github:ndom91/rose-pine-hyprcursor";
			inputs.nixpkgs.follows = "nixpkgs-base";
		};
	};

	outputs = { ... }@inputs:
		(import ./modules/devices) inputs;
}
