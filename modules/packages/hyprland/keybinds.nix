{ lib, ... }:
let mainMod = "Super";
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

				# Screenshot: Super + Shift + S
				("${mainMod} Shift, S, exec, " +
					''grim -g "$(slurp -b '#000000a0' -c '#ffffff30' -w 1)" - | wl-copy &&'' +
					''notify-send "Screenshot Taken"'')

				# Picker: Super + Shift + P
				("${mainMod} Shift, P, exec, " +
					''wl-copy -p $(hyprpicker -a) && notify-send "Color Picked"'')
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

