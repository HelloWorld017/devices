{ pkgs, ... }:
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
		./plymouth.nix
		./screenshot.nix
		./swayosd.nix
		./themes.nix
	];

	config = {
		home.packages = with pkgs; [
			quickshell
		];

		environment.sessionVariables = {
			NIXOS_OZONE_WL = "1";
		};
	};
}
