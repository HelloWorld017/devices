{ self, pkgs, ... }:
let repo = import "${self}/modules/packages";
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
			discord
			eza
			fastfetch
			fastmod
			fd
			ffmpeg
			figma-linux
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
			nodePackages.pnpm
			pkg-config
			podman
			podman-compose
			protobuf
			python314
			pv
			ripgrep
			smartmontools
			spotify
			tealdeer
			telegram-desktop
			thefuck
			unzip
			usbutils
			verapdf
			virtualenv
			wev
			wl-clipboard
			yt-dlp
			zip
		];
	};
}
