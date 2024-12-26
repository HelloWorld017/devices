{ pkgs, ... }:
{
	config = {
		home.wayland.windowManager.hyprland = {
			plugins = [ pkgs.hyprlandPlugins.hyprbars ];
			settings = {
				plugin = {
					hyprbars = {
						bar_blur = true;
						bar_text_font = "Pretendard JP Semibold";
						bar_text_size = 9;
						bar_height = 35;
						bar_padding = 20;
						bar_button_padding = 10;
						hyprbars-button = [
							"rgb(ff4040), 8, , hyprctl dispatch killactive"
							"rgb(eeeeee), 8, , hyprctl dispatch fullscreen 1"
						];
					};
				};
			};
		};
	};
}

