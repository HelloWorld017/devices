{ pkgs, repo, ... }:
{
	imports = [
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
			fastfetch
			fastmod
			fd
			ffmpeg
			file
			fzf
			inetutils
			jq
			nodejs
			nodePackages.pnpm
			pkg-config
			pv
			ripgrep
			tealdeer
			thefuck
			unzip
			virtualenv
			yt-dlp
			zip
		];
	};
}
