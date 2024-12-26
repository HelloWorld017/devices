{ self, pkgs, ... }:
let repo = import "${self}/modules/packages";
in {
	imports = [
		repo.alacritty
		repo.anyrun
		repo.firefox
		repo.fonts
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
			chromium
			cmake
			discord
			docker
			docker-compose
			eza
			fastmod
			fd
			ffmpeg
			fzf
			jq
			kubectl
			musescore
			nodejs
			nodePackages.pnpm
			pkg-config
			python314
			pv
			ripgrep
			spotify
			tealdeer
			telegram-desktop
			thefuck
			virtualenv
			wl-clipboard
			(repo.overrides.keeweb pkgs)
		];
	};
}
