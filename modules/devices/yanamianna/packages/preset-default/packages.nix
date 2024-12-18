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
			wget
			git
		];

		home.packages = with pkgs; [
			bat
			btop
			eza
			fastmod
			fd
			fzf
			jq
			kubectl
			nodejs
			nodePackages.pnpm
			pkg-config
			python314
			pv
			ripgrep
			tealdeer
			thefuck
			virtualenv
			wget
		];
	};
}
