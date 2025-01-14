{ pkgs, repo, inputs, system, ... }:
{
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
			# verapdf: build error in 1.26.4
			virtualenv
			wev
			wl-clipboard
			yt-dlp
			zip

			inputs.figma-linux.packages.${system}.default
		];
	};
}
