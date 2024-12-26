{ lib, pkgs, options, ... }:
{
	config = lib.mkMerge [
		(if options ? "homebrew" then {
			homebrew.casks = [ "alacritty" ];
		} else {
			home.packages = [ pkgs.alacritty ];
		})
		({
			home.configFile."alacritty/alacritty.toml".text =
				(builtins.readFile ./assets/alacritty.toml);
		})
	];
}
