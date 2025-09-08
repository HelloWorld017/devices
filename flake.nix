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

		std = { url = "github:chessai/nix-std"; };
		wsl = { url = "github:nix-community/NixOS-WSL/main"; };

		# Other Inputs
		figma-linux = {
			url = "github:HelloWorld017/figma-linux-nixos";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		ghostty = { url = "github:ghostty-org/ghostty"; };
		hyprshell = {
			url = "github:h3rmt/hyprshell/hyprshell-release";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		neovim-nightly = {
			url = "github:nix-community/neovim-nightly-overlay";
			inputs.nixpkgs.follows = "nixpkgs-rolling";
		};

		nnf = { url = "github:thelegy/nixos-nftables-firewall"; };
	};

	outputs = { ... }@inputs:
		(import ./modules/devices) inputs;
}
