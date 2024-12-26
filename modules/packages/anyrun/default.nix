{ inputs, pkgs, ... }:
{
	config = {
		home-manager.sharedModules = [
			inputs.anyrun.homeManagerModules.default
		];

		home.programs.anyrun = {
			enable = true;
			config = {
				x = { fraction = 0.5; };
				y = { fraction = 0.3; };
				width = { fraction = 0.3; };
				plugins =
					let anyrunPkgs = inputs.anyrun.packages.${pkgs.system};
					in with anyrunPkgs; [
						applications
						dictionary
						rink
						shell
						symbols
						translate
						websearch
					];
			};

			extraCss = (builtins.readFile ./assets/style.css);
			extraConfigFiles = {
				"applications.ron".text = ''
					Config(
						desktop_actions: false,
						max_entries: 5,
						terminal: Some("alacritty")
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
