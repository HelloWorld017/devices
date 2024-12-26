{ pkgs, lib, config, ... }:
{
	imports = [
		./hyprbars.nix
		./keybinds.nix
	];

	options = with lib.types; {
		pkgs.hyprland = {
			scale = lib.mkOption {
				type = float;
				default = 1.5;
				description = "Scale of display";
			};
		};
	};

	config = {
		programs.hyprland = {
			enable = true;
			withUWSM = true;
			xwayland.enable = true;
		};

		home.wayland.windowManager.hyprland = {
			enable = true;
			settings = {
				input = {
					repeat_rate = 40;
					repeat_delay = 300;
				};

				xwayland = {
					force_zero_scaling = true;
				};
			};
			plugins = with pkgs.hyprlandPlugins; [
				hy3
			];
		};

		environment.sessionVariables = {
			NIXOS_OZONE_WL = "1";
			GDK_SCALE = (builtins.toString config.pkgs.hyprland.scale);
			XCURSOR_SIZE = (builtins.toString (16 * config.pkgs.hyprland.scale));
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
