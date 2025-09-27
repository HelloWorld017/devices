{ ... }:
{
	config = {
		home.services.hyprshell = {
			enable = true;
			settings = {
				overview = null;
				windows = {
					scale = 5.5;
					items_per_row = 5;
					switch = {
						modifier = "alt";
					};
				};
			};
		};

		home.wayland.windowManager.hyprland.settings = {
			exec-once = [
				"hyprshell run &"
			];
		};
	};
}
