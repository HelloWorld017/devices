{ config, lib, pkgs, ... }:

{
	config = lib.mkIf pkgs.stdenv.isDarwin {
		homebrew.casks = [
			"karabiner-elements"
		];

		home.file.".config/karabiner/karabiner.json".text =
			(builtins.readFile ./assets/karabiner.json);
	};
}

