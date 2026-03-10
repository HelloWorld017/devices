{ pkgs, inputs, system, ... }:

let
	tuiSettings = {
		"input_submit" = "return";
		"input_newline" = "shift+return";
		"theme" = "cursor";
	};
in {
	config = {
		home.packages = [
			inputs.opencode.packages.${system}.default
		];

		home.configFile = {
			"opencode/tui.json" = let
				json = pkgs.formats.json { };
			in {
				source = json.generate "tui.json" tuiSettings;
			};
		};
	};
}
