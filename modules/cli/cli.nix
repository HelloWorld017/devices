{ config, lib, pkgs, ... }:

{
	config = {
		home.packages = with pkgs; [
			awscli
			bat
			btop
			exa
			fzf
			jq
			nodejs
			ripgrep
			thefuck
			yarn
		];
	};
}
