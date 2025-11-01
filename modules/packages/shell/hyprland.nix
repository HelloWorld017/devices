{ pkgs, lib, config, ... }:
{
	options = with lib.types; {
		pkgs.shell.hyprland = {
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
					gaps_out = 12;
					border_size = 3;
					resize_on_border = true;
					"col.inactive_border" = "rgba(ffffff30)";
					"col.active_border" = "rgba(ffffffa0)";
					"col.nogroup_border" = "rgba(ffffff30)";
					"col.nogroup_border_active" = "rgba(ffffffa0)";
				};

				decoration = {
					rounding = 15;

					shadow = {
						enabled = true;
						range = 8;
						render_power = 2;
						color = "rgba(00000040)";
						color_inactive = "rgba(00000000)";
					};

					blur = {
						enabled = true;
						size = 12;
						passes = 1;
						vibrancy = 0.1696;
					};
				};

				group = {
					groupbar = {
						render_titles = false;
						rounding = 4;
						indicator_height = 3;
						"col.active" = "rgba(ffffffa0)";
						"col.inactive" = "rgba(ffffff30)";
						"col.locked_active" = "rgba(303030ff)";
						"col.locked_inactive" = "rgba(30303080)";
						gaps_in = 16;
						gaps_out = 8;
					};


					"col.border_inactive" = "rgba(ffffff30)";
					"col.border_active" = "rgba(ffffffa0)";
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
					"GDK_SCALE,${asString config.pkgs.shell.hyprland.scale}"
					"XCURSOR_SIZE,${asIntString (16 * config.pkgs.shell.hyprland.scale)}"
					"HYPRCURSOR_SIZE,${asIntString (16 * config.pkgs.shell.hyprland.scale)}"
				];

				input = {
					repeat_rate = 40;
					repeat_delay = 300;
					follow_mouse = 2;
					float_switch_override_focus = 0;
					numlock_by_default = true;

					touchpad = {
						disable_while_typing = false;
					};
				};

				workspace = [
					"w[tv1]s[false], gapsout:0, gapsin:0"
					"f[1]s[false], gapsout:6, gapsin:0"
				];

				windowrule = [
					"bordersize 0, floating:0, onworkspace:w[tv1]s[false]"
					"rounding 0, floating:0, onworkspace:w[tv1]s[false]"
					"rounding 6, floating:0, onworkspace:f[1]s[false]"
					"float, workspace:10"
					"bordercolor rgb(5e81ac) rgb(d8dee9),fullscreen:1"
					"float, class:^(xdg-desktop-portal-gtk)$"
					"pin, class:^(it.catboy.ripdrag)$"
				];

				xwayland = {
					force_zero_scaling = true;
				};
			};

			plugins = with pkgs.hyprlandPlugins; [
				hy3
			];
		};

		home.packages = with pkgs; [
			hyprpicker
		];

		services.displayManager = {
			gdm = {
				enable = true;
				wayland = true;
			};
		};
	};
}
