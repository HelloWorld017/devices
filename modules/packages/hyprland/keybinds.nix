{ lib, ... }:
let
	mainMod = "Super";
	mkArrow = mod: action: args:
		lib.map
			(item: "${mod}, ${item.fst}, ${action}, ${item.snd}")
			(lib.zipLists ["H" "J" "K" "L" "left" "down" "up" "right"] (args ++ args));
	mkNum = mod: action: args:
		lib.map
			(item: "${mod}, ${toString item.fst}, ${action}, ${toString item.snd}")
			(lib.zipLists ((lib.range 1 9) ++ [0]) args);
in {
	config = {
		home.wayland.windowManager.hyprland.settings = {
			bind = lib.flatten [
				# Close: Super + Q
				"${mainMod}, Q, killactive"

				# Focus: Super + (HJKL / Arrow)
				(mkArrow mainMod "movefocus" ["l" "d" "u" "r"])

				# Move: Super + Ctrl + (HJKL / Arrow)
				(mkArrow "${mainMod} Ctrl" "swapwindow" ["l" "d" "u" "r"])

				# Zoom: Super + Z
				"${mainMod}, Z, fullscreen, 1"

				# Workspace: Super + Num / Super + (Shift +) Tab / Super + Scroll
				(mkNum mainMod "workspace" (lib.range 1 10))
				"${mainMod}, tab, workspace, m+1"
				"${mainMod} Shift, tab, workspace, m-1"
				"${mainMod}, mouse_down, workspace, e+1"
				"${mainMod}, mouse_up, workspace, e-1"

				# Workspace: Super + Shift + Num
				(mkNum "${mainMod} Shift" "movetoworkspacesilent" (lib.range 1 10))

				# Workspace: Super + Num
				# Launcher: Alt + Space
				"Alt, Space, exec, pkill anyrun || anyrun"

				# Group: Super + (Shift +) G
				"${mainMod}, G, togglegroup"
				"${mainMod} Shift, G, moveoutofgroup, active"

				# Group Rotation: Super + ][
				"${mainMod}, bracketleft, changegroupactive, f"
				"${mainMod}, bracketright, changegroupactive, b"

				# Lock: Super + Ctrl + Q
				"${mainMod} Ctrl, Q, exec, loginctl lock-session"

				# Screenshot: Super + Shift + S
				("${mainMod} Shift, S, exec, " +
					''grim -g "$(slurp -b 000000a0 -c ffffff30 -w 1)" - | wl-copy && '' +
					''notify-send "Screenshot Taken"'')

				# Picker: Super + Shift + P
				("${mainMod} Shift, P, exec, " +
					''wl-copy -p $(hyprpicker -a) && notify-send "Color Picked"'')
			];

			binde = lib.flatten [
				# Resize: Super + Shift + (HJKL / Arrow)
				(mkArrow "${mainMod} Shift" "resizeactive" ["-10 0" "0 10" "0 -10" "10 0"])
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

