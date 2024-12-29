{ inputs, system,... }:
{
	config = {
		home.packages = [ inputs.hyprswitch.packages.${system}.default ];
		home.wayland.windowManager.hyprland.settings = {
			exec-once = [
				"hyprswitch init --show-title --size-factor 5.5 --workspaces-per-row 5 &"
			];
		};
	};
}
