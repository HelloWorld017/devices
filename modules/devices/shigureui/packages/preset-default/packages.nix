{ pkgs, rollingPkgs, repo, inputs, system, ... }:
let
	patchedPkgs = (repo.patches pkgs);
in {
	imports = [
		repo.alacritty
		repo.anyrun
		repo.firefox
		repo.fonts
		repo.git
		repo.hyprland
		repo.ime
		repo.midnightway
		repo.nvim
		repo.tmux
		repo.zsh
	];

	config = {
		environment.systemPackages = with pkgs; [
			clang_19
			coreutils
			git
			wget
		];

		home.packages = with pkgs; [
			inputs.agenix.packages.${system}.default
			android-tools
			bat
			better-control
			binwalk
			blender
			btop
			buildah
			chromium
			jetbrains.clion
			cmake
			dig
			eza
			fastfetch
			fastmod
			fd
			ffmpeg
			inputs.figma-linux.packages.${system}.default
			file
			fzf
			ghostscript
			gjs
			gnome-text-editor
			inetutils
			jq
			keeweb
			kubectl
			lm_sensors
			loupe
			nautilus
			nodejs
			inputs.notion-linux.packages.${system}.default
			onlyoffice-bin
			pkg-config
			nodePackages.pnpm
			podman
			podman-compose
			protobuf
			pulseaudio
			python314
			pv
			jetbrains.rider
			ripdrag
			ripgrep
			smartmontools
			parsec-bin
			patchedPkgs.spotify
			slack
			tealdeer
			telegram-desktop
			unityhub
			unzip
			usbutils
			rollingPkgs.vesktop
			virtualenv
			wev
			wl-clipboard
			yt-dlp
			zip
		];
	};
}
