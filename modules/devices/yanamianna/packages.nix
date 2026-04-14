{ pkgs, repo, inputs, system, ... }:
{
	imports = [
		repo.fastfetch
		repo.git
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
			bat
			binwalk
			btop
			buildah
			cmake
			dig
			eza
			fastmod
			fd
			ffmpeg
			file
			fzf
			ghostscript
			inetutils
			jq
			kubectl
			lm_sensors
			net-tools
			nodejs
			pkg-config
			nodePackages.pnpm
			podman
			podman-compose
			protobuf
			python314
			pv
			ripgrep
			smartmontools
			tealdeer
			unzip
			usbutils
			# verapdf: build error in 1.26.4
			virtualenv
			wakeonlan
			wev
			wl-clipboard
			yt-dlp
			zip
		];
	};
}
