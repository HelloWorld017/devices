{ lib, ... }:
let mainMod = "SUPER";
in {
	config = {
		home.wayland.windowManager.hyprland.settings = {
			bind = [
				# Close: Super + Q
				"${mainMod}, Q, killactive"

				# Focus: Super + HJKL
				"${mainMod}, H, movefocus, l"
				"${mainMod}, J, movefocus, d"
				"${mainMod}, K, movefocus, u"
				"${mainMod}, L, movefocus, r"

				# Launcher: Alt + Space
				"Alt, Space, exec, pkill anyrun || anyrun"

				# Group: Super + G
				"${mainMod}, G, togglegroup"
			];

			bindm = [
				# Move: Super + LMB
				"${mainMod}, mouse:272, movewindow"

				# Resize: Super + RMB
				"${mainMod}, mouse:273, resizewindow"
			];
		};
	};
}

