{ pkgs, repo, inputs, system, ... }:
let
	patchedPkgs = (repo.patches pkgs);
in {
	imports = [
		repo.alacritty
		repo.anyrun
		repo.fastfetch
		repo.firefox
		repo.fonts
		repo.ghostty
		repo.git
		repo.shell
		repo.ime
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
			android-tools
			bat
			binwalk
			blender-hip
			btop
			buildah
			chromium
			cmake
			dig
			eza
			fastmod
			fd
			ffmpeg
			inputs.figma-linux.packages.${system}.default
			file
			fzf
			ghostscript
			gjs
			inetutils
			jq
			keeweb
			kubectl
			lm_sensors
			loupe
			musescore
			nautilus
			nodejs
			obs-studio
			pkg-config
			nodePackages.pnpm
			podman
			podman-compose
			prismlauncher
			protobuf
			python314
			pv
			ripgrep
			smartmontools
			patchedPkgs.spotify
			tealdeer
			telegram-desktop
			unzip
			usbutils
			# verapdf: build error in 1.26.4
			vesktop
			virtualenv
			wakeonlan
			wev
			wl-clipboard
			yt-dlp
			zip
		];
	};
}
