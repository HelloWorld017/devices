{ pkgs, rollingPkgs, repo, inputs, system, ... }:
let
	patchedPkgs = (repo.patches pkgs);
in {
	imports = [
		repo.alacritty
		repo.anyrun
		repo.firefox
		repo.fonts
		repo.ghostty
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
			inputs.agenix.packages.${system}.default
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
			pkg-config
			nodePackages.pnpm
			podman
			podman-compose
			protobuf
			pulseaudio
			python314
			pv
			jetbrains.rider
			ripgrep
			smartmontools
			parsec-bin
			patchedPkgs.spotify
			slack
			tealdeer
			telegram-desktop
			(pkgs.unityhub.override {
				extraLibs = pkgs: with pkgs; [ openssl_1_1 ];
			})
			unzip
			usbutils
			rollingPkgs.vesktop
			virtualenv
			wev
			wl-clipboard
			yt-dlp
			zip
		];

		nixpkgs.config.permittedInsecurePackages = [
			"openssl-1.1.1w"
		];
	};
}
