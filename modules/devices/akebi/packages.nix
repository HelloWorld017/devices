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
			nodePackages.pnpm
			pkg-config
			pv
			ripgrep
			tealdeer
			unzip
			virtualenv
			latestPkgs.yt-dlp
			zip
		];
	};
}
