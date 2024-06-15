{ config, lib, pkgs, ... }:
{
	config = {
		homebrew.casks = [
			"blender"
			"docker"
			"dozer"
			"figma"
			"fontforge"
			"fuwari"
			"gureumkim"
			"homebrew/cask-versions/firefox-developer-edition"
			"kap"
			"phpstorm"
			"postman"
			"rectangle"
			"spotify"
			"sublime-text"
		];

		home.packages = with pkgs; [
			argocd
			android-tools
			awscli
			bat
			btop
			chafa
			coreutils
			darwin.iproute2mac
			docker-compose
			elixir
			ffmpeg
			eza
			fastmod
			fd
			fzf
			imagemagick
			jq
			kubectl
			kubernetes-helm
			nodejs
			nodePackages.pnpm
			nodePackages.yarn
			pkg-config
			php
			python311
			pv
			ripgrep
			spicetify-cli
			tealdeer
			thefuck
			virtualenv
			wget
		];
	};
}

