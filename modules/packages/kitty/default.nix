{ options, lib, pkgs, ... }:
{
	config = lib.mkMerge [
		(if (builtins.hasAttr "homebrew" options) then {
			homebrew.casks = [ "kitty" ];
		} else {
			home.packages = [ pkgs.kitty ];
		})
		({
			home.configFile."kitty/kitty.conf".text =
				(builtins.readFile ./assets/kitty.conf);

			home.programs.zsh = {
				shellAliases = {
					icat = "kitty +kitten icat";
				};
			};
		})
	];
}
