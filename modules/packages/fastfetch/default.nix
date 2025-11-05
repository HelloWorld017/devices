{ pkgs, ... }:
{
	config = {
		home.packages = with pkgs; [ fastfetch ];
		home.configFile = {
			"fastfetch/config.jsonc".source = ./assets/config.jsonc;
			"fastfetch/logo.png".source = ./assets/logo.png;
		};

		home.configFile."fastfetch/config.jsonc".text = 
			(builtins.readFile ./assets/config.jsonc);
	};
}
