{ pkgs, lib, ... }:
{
	config = {
		home.programs.anyrun = {
			enable = true;
			config = {
				x = { fraction = 0.5; };
				y = { fraction = 0.3; };
				width = lib.mkDefault { fraction = 0.3; };
				plugins = [
					"${pkgs.anyrun}/lib/libapplications.so"
					"${pkgs.anyrun}/lib/libdictionary.so"
					"${pkgs.anyrun}/lib/librink.so"
					"${pkgs.anyrun}/lib/libshell.so"
					"${pkgs.anyrun}/lib/libsymbols.so"
					"${pkgs.anyrun}/lib/libtranslate.so"
					"${pkgs.anyrun}/lib/libwebsearch.so"
				];
			};

			extraCss = (builtins.readFile ./assets/style.css);
			extraConfigFiles = {
				"applications.ron".text = ''
					Config(
						desktop_actions: false,
						max_entries: 5,
						terminal: Some(Terminal(
							command: "alacritty",
							args: "-e {}",
						))
					)
				'';

				"dictionary.ron".text = ''
					Config(
						prefix: "!dict",
						max_entries: 5
					)
				'';

				"shell.ron".text = ''
					Config(
						prefix: "!#",
						shell: None
					)
				'';

				"symbols.ron".text = ''
					Config(
						prefix: "!sym",
						symbols: {},
						max_entries: 3
					)
				'';

				"translate.ron".text = ''
					Config(
						prefix: "!t",
						language_delimiter: ">",
						max_entries: 1,
					)
				'';

				"websearch.ron".text = ''
					Config(
						prefix: "!!",
						engines: [Google]
					)
				'';
			};
		};
	};
}
