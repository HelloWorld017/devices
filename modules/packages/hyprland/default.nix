{ pkgs, lib, config, ... }:
{
	imports = [
		./hypridle.nix
		./hyprlock.nix
		./hyprswitch.nix
		./keybinds.nix

		# ./hyprbars.nix
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
				general = {
					resize_on_border = true;
				};

				decoration = {
					rounding = 15;

					shadow = {
						enabled = true;
						range = 4;
						render_power = 3;
						color = "rgba(1a1a1aee)";
					};

					blur = {
						enabled = true;
						size = 12;
						passes = 1;
						vibrancy = 0.1696;
					};
				};

				env = let
					asString = val: builtins.toJSON val;
					asIntString = val: asString (builtins.ceil val);
				in [
					# Should not add QT_QPA_PLATFORM,wayland
					# > Some applications have bugs with wayland (e.g. MuseScore).
					# > The nixpkg already handles them.

					"QT_AUTO_SCREEN_SCALE_FACTOR,1"
					"QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
					"GDK_SCALE,${asString config.pkgs.hyprland.scale}"
					"XCURSOR_SIZE,${asIntString (16 * config.pkgs.hyprland.scale)}"
					"HYPRCURSOR_SIZE,${asIntString (16 * config.pkgs.hyprland.scale)}"
				];

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

		home.packages = with pkgs; [
			grim
			hyprpicker
			slurp
		];

		environment.sessionVariables = {
			NIXOS_OZONE_WL = "1";
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
