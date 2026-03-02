{ pkgs, repo, latestPkgs, ... }:
{
	imports = [
		repo.fastfetch
		repo.git
		repo.nvim
		repo.tmux
		repo.wsl
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
			bat
			binwalk
			btop
			cmake
			dig
			eza
			fastmod
			fd
			ffmpeg
			file
			fzf
			inetutils
			jq
			net-tools
			nodejs
			latestPkgs.opencode
			nodePackages.pnpm
			pkg-config
			podman
			podman-compose
			pv
			python314
			ripgrep
			tealdeer
			unzip
			uv
			virtualenv
			latestPkgs.yt-dlp
			zip
		];
	};
}
