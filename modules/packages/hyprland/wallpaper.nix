{ lib, config }:
{
	options = with lib.types; {
		pkgs.hyprland = {
			wallpaperDirectory = lib.mkOption {
				type = str;
				nullable = true;
				description = "Directory of wallpapers";
			};
		};
	};

	config = 
		let
			wallpaperDirectory = config.pkgs.hyprland.wallpaperDirectory;
		in lib.mkIf wallpaperDirectory {
			home.configFile."hypr/scripts/wallpaper_roll.sh".text = ''
				#! /usr/bin/env zsh

				WALLPAPER_DIR="$HOME/wallpapers/"
				CURRENT_WALL=$(hyprctl hyprpaper listloaded)
				WALLPAPER=$(find "${wallpaperDirectory}" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)

				hyprctl hyprpaper reload ,"$WALLPAPER"
			'';

			home.wayland.windowManager.hyprland.settings = {
				exec-once = [
					"hyprpaper"
					"~/.config/hypr/scripts/wallpaper_roll.sh"
				];
			};

			home.services.hyprpaper = {
				enable = true;
			};
		};
}
