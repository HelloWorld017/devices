{ inputs, system, ... }:
{
	config = {
		home.packages = [ inputs.ghostty.packages.${system}.default ];
		home.configFile."ghostty/config".text =
			builtins.readFile ./assets/ghostty_config;
	};
}
