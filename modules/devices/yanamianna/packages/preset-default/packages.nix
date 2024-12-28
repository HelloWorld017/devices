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
			btop
			buildah
			chromium
			cmake
			discord
			eza
			fastfetch
			fastmod
			fd
			ffmpeg
			figma-linux
			fzf
			jq
			keeweb
			kubectl
			lm_sensors
			musescore
			nodejs
			nodePackages.pnpm
			pkg-config
			podman
			podman-compose
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
			virtualenv
			wl-clipboard
			zip
		];
	};
}
