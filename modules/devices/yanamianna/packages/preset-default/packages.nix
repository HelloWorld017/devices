{ self, pkgs, ... }:
{
	imports =
		let pkgs = import "${self}/modules/packages";
		in
			[
				pkgs.alacritty
				pkgs.anyrun
				pkgs.firefox
				pkgs.fonts
				pkgs.git
				pkgs.hyprland
				pkgs.nvim
				pkgs.tmux
				pkgs.zsh
			];

	config = {
		environment.systemPackages = with pkgs; [
			coreutils
			git
			llvmPackages_19.llvm
			wget
		];

		home.packages = with pkgs; [
			android-tools
			bat
			btop
			chromium
			cmake
			docker
			docker-compose
			eza
			fastmod
			fd
			ffmpeg
			fzf
			jq
			keeweb
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
			thefuck
			virtualenv
		];
	};
}
