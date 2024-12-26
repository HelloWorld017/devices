{ pkgs, ... }:
{
	config = {
		home.wayland.windowManager.hyprland = {
			plugins = [ pkgs.hyprlandPlugins.hyprbars ];
			settings = {
				plugins = {
					hyprbars = {
						bar_height = 100;
						hyprbars-button = [
							"rgb(ff4040), 10, x, hyprctl dispatch killactive"
						];
					};
				};
			};
		};
	};
}

