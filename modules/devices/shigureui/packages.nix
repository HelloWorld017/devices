{ pkgs, repo, inputs, system, latestPkgs, ... }:
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
			inputs.agenix.packages.${system}.default
			android-tools
			bat
			better-control
			binwalk
			latestPkgs.blender
			btop
			buildah
			chromium
			jetbrains.clion
			cmake
			inputs.nix-index-database.packages.${system}.comma-with-db
			curlie
			dig
			eza
			fastmod
			fd
			ffmpeg
			inputs.figma-linux.packages.${system}.default
			file
			file-roller
			fzf
			ghostscript
			gjs
			gnome-text-editor
			gnumake
			inetutils
			jq
			keeweb
			kubectl
			lm_sensors
			loupe
			nautilus
			net-tools
			nodejs
			inputs.notion-linux.packages.${system}.default
			onlyoffice-bin
			parsec-bin
			pinta
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
			rquickshare
			slack
			smartmontools
			patchedPkgs.spotify
			tealdeer
			telegram-desktop
			unityhub
			unzip
			usbutils
			uv
			vesktop
			virtualenv
			wev
			wl-clipboard
			latestPkgs.yt-dlp
			zip
		];
	};
}
