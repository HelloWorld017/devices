{ pkgs, ... }:
{
	config = {
		home.packages = with pkgs; [ ghostty ];
		home.configFile."ghostty/config".text =
			builtins.readFile ./assets/ghostty_config;
	};
}
