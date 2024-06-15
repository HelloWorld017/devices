{ config, lib, pkgs, ... }:
{
	config = lib.mkMerge [
		(lib.mkIf pkgs.stdenv.isDarwin {
			homebrew.casks = [
				"alacritty"
			];
		})
		(lib.mkIf (!pkgs.stdenv.isDarwin) {
			home.packages = with pkgs; [ alacritty ];
		})
		({
			home.file.".config/kitty/kitty.conf".text =
				(builtins.readFile ./assets/kitty.conf);

			home.programs.zsh = {
				shellAliases = {
					icat = "kitty +kitten icat";
				};
			};
		})
	];
}
