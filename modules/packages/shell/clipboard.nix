{ pkgs, ... }:
{
	config = {
		home.packages = with pkgs; [
			wl-clip-persist
		];

		home.wayland.windowManager.hyprland.settings = {
			exec-once = [
				"wl-clip-persist --clipboard regular"
			];
		};
	};
}
