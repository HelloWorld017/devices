{ pkgs, repo, inputs, system, ... }:
{
	imports = [
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
			curlie
			dig
			eza
			fastfetch
			fastmod
			fd
			ffmpeg
			file
			fzf
			inetutils
			jq
			kubectl
			nodejs
			pkg-config
			nodePackages.pnpm
			podman
			podman-compose
			python314
			pv
			ripgrep
			smartmontools
			tealdeer
			unzip
			virtualenv
			yt-dlp
			zip
		];
	};
}
