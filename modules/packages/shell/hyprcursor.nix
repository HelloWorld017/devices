{ inputs, system, ... }:
{
	config = {
		home.wayland.windowManager.hyprland = {
			settings = {
				env = [
					"HYPRCURSOR_THEME,rose-pine-hyprcursor"
				];
			};
		};

		home.packages = [
			inputs.rose-pine-hyprcursor.packages.${system}.default
		];
	};
}
