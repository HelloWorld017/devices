{ inputs, system, ... }:
{
	imports = [
		./clipboard.nix
		./hyprcursor.nix
		./hypridle.nix
		./hyprland.nix
		./hyprlock.nix
		./hyprshell.nix
		./hyprpaper.nix
		./keybinds.nix
		./midnightway.nix
		./screenshot.nix
		./swayosd.nix
		./themes.nix
	];

	config = {
		home.packages = [
			inputs.quickshell.packages.${system}.default
		];

		environment.sessionVariables = {
			NIXOS_OZONE_WL = "1";
		};
	};
}
