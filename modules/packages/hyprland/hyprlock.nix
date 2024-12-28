{ ... }:
{
	security.pam.services.hyprlock = {};

	home.programs.hyprlock = {
		enable = true;
		settings = {
			background = [
				{
					path = "screenshot";
					blur_passes = 3;
					blur_size = 20;
					contrast = 0.8916;
					brightness = 0.7172;
					vibrancy = 0.1696;
					vibrancy_darkness = 0;
				}
			];

			label = let
					shadow = {
						shadow_pass = 2;
						shadow_size = 3;
						shadow_color = "rgb(0,0,0)";
						shadow_boost = 1.2;
					};
				in [
					({
						text = ''cmd[update:1000] echo -e "$(date +"%H:%M")"'';
						color = "rgba(255, 255, 255, 1)";
						font_size = 150;
						font_family = "Aquatico";
						position = "300, -300";
						halign = "left";
						valign = "top";
					} // shadow)
					({
						text = ''cmd[update:1000] echo -e "$(date +"%b %d %A")"'';
						color = "rgba(255, 255, 255, 0.7)";
						font_size = 24;
						font_family = "Pretendard JP";
						position = "330, -560";
						halign = "left";
						valign = "top";
					} // shadow)
				];

			input-field = [
				{
					size = "250, 60";
					outline_thickness = 1;
					outer_color = "rgba(255, 255, 255, 0.05)";
					dots_size = 0.1;
					dots_spacing = 1;
					dots_center = true;
					check_color = "rgba(255, 255, 255, 0.1)";
					fail_color = "rgba(204, 34, 34, 0.1)";
					inner_color = "rgba(10, 10, 10, 0)";
					font_color = "rgba(200, 200, 200, 1)";
					fade_on_empty = false;
					font_family = "Pretendard JP";
					placeholder_text = ''<span foreground="##cdd6f4">$USER</span>'';
					hide_input = false;
					position = "0, -470";
					halign = "center";
					valign = "center";
					zindex = 10;
				}
			];
		};
	};
}
