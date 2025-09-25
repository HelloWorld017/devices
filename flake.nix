{
	description = "nenw's Flake";

	inputs = {
		# Core Inputs
		nixpkgs = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
		nixpkgs-rolling = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
		darwin = {
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		agenix = {
			url ="github:ryantm/agenix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		agenix-template = { url = "github:jhillyerd/agenix-template/1.0.0"; };
		std = { url = "github:chessai/nix-std"; };
		wsl = { url = "github:nix-community/NixOS-WSL/main"; };

		# Other Inputs
		figma-linux = {
			url = "github:HelloWorld017/figma-linux-nixos";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		ghostty = {
			url = "github:ghostty-org/ghostty";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		hyprshell = {
			url = "github:h3rmt/hyprshell/hyprshell-release";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		midnightway = {
			url = "github:HelloWorld017/midnightway";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nnf = { url = "github:thelegy/nixos-nftables-firewall"; };
		notion-linux = {
			url = "github:HelloWorld017/notion-linux-nixos";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		rose-pine-hyprcursor = {
			url = "github:ndom91/rose-pine-hyprcursor";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { ... }@inputs:
		(import ./modules/devices) inputs;
}
