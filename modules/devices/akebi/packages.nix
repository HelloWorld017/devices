{ pkgs, repo, ... }:
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
			nodejs
			nodePackages.pnpm
			pkg-config
			pv
			ripgrep
			tealdeer
			unzip
			virtualenv
			yt-dlp
			zip
		];
	};
}
