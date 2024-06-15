{ config, lib, pkgs, ... }:

{
	config = lib.mkMerge [
		(lib.mkIf pkgs.stdenv.isDarwin {
			homebrew.casks = [
				"kitty"
			];
		})
		(lib.mkIf (!pkgs.stdenv.isDarwin) {
			home.packages = with pkgs; [ kitty ];
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
