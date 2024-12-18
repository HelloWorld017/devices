{ ... }:
{
	imports = [
		./keybinds.nix
	];

	config = {
		programs.hyprland = {
			enable = true;
			withUWSM = true;
			xwayland.enable = true;
		};

		home.wayland.windowManager.hyprland = {
			enable = true;
		};

		services.xserver = {
			displayManager = {
				gdm = {
					enable = true;
					wayland = true;
				};
			};
		};
	};
}
