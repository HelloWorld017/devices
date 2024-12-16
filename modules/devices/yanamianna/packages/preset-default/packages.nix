{ config, lib, pkgs, ... }:
{
	config = {
		environment.systemPackages = with pkgs; [
			wget
			git
		];

		home.packages = with pkgs; [
			bat
			btop
			eza
			fastmod
			fd
			fzf
			jq
			kubectl
			nodejs
			nodePackages.pnpm
			pkg-config
			python314
			pv
			ripgrep
			tealdeer
			thefuck
			virtualenv
			wget
		];
	};
}
