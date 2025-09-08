{ inputs, system,... }:
{
	config = {
		home.packages = [ inputs.hyprshell.packages.${system}.default ];
		home.wayland.windowManager.hyprland.settings = {
			exec-once = [
				"hyprshell init --show-title --size-factor 5.5 --workspaces-per-row 5 &"
			];
		};
	};
}
