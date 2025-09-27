{ ... }:
{
	config = {
		home.services.swayosd.enable = true;

		home.wayland.windowManager.hyprland.settings = {
			bind = [
				", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
				", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
			];

			binde = [
				", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
				", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
				", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
				", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
			];
		};
	};
}
