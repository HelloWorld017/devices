{ config, ... }:
{
	config = {
		home.services.hypridle = {
			enable = true;
			settings = {
				general = {
					lock_cmd = "pidof hyprlock || hyprlock";
					before_sleep_cmd = let
						wallpaperRoll = if config.pkgs.shell.wallpaper.directory != null then
							" && ~/.config/hypr/scripts/wallpaper_roll.sh"
						else "";
					in "loginctl lock-session ${wallpaperRoll}";
					after_sleep_cmd = "hyprctl dispatch dpms on";
					ignore_dbus_inhibit = false;
				};

				listener = [
					{
						timeout = 540;
						on-timeout = "brightnessctl -s set 10";
						on-resume = "brightnessctl -r";
					}
					{
						timeout = 600;
						on-timeout = "hyprctl dispatch dpms off";
						on-resume = "hyprctl dispatch dpms on";
					}
					{
						timeout = 630;
						on-timeout = "loginctl lock-session";
					}
				];
			};
		};
	};
}

