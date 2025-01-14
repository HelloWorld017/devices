{ lib, pkgs, inputs, config, options, ... }:
{
	options = with lib.types; {
		pkgs.alacritty = {
			useClaritty = lib.mkOption {
				type = bool;
				default = false;
				description = "Use HelloWorld017/claritty for the package (WIP)";
			};
		};
	};

	config = let
		alacrittyConfig = {
			general = {
				live_config_reload = true;
			};

			window = {
				decorations = "transparent";
				opacity = 0.75;
			};

			font = {
				size = 12;
				bold = {
					family = "Sarasa Term K Nerd Font";
					style = "Bold";
				};

				normal = {
					family = "Sarasa Term K Nerd Font";
					style = "Regular";
				};

				offset = {
					y = 5;
				};
			};

			colors = {
				normal = {
					black =   "0x002221";
					red =     "0xea3431";
					green =   "0x00b6b6";
					yellow =  "0xf8b017";
					blue =    "0x4894fd";
					magenta = "0xe01dca";
					cyan =    "0x1ab2ad";
					white =   "0x99dddb";
				};

				bright = {
					black =   "0x006562";
					red =     "0xea3431";
					green =   "0x00b6b6";
					yellow =  "0xf8b017";
					blue =    "0x4894fd";
					magenta = "0xe01dca";
					cyan =    "0x1ab2ad";
					white =   "0xe6f6f6";
				};
			};

			window.padding = {
				x = 15;
				y = 15;
			};
		};

		clarittyConfig = {
			window.padding = {
				top = 30;
				left = 15;
				right = 10;
				bottom = 0;
			};

			scrollbar = {
				mode = "Fading";
				color = "#ffffff";
				opacity = 0.3;
			};
		};
	in lib.mkMerge [
		{
			home.configFile."alacritty/alacritty.toml".text = inputs.std.lib.serde.toTOML
				(alacrittyConfig // (if config.pkgs.alacritty.useClaritty then clarittyConfig else {}));
		}

		(if options ? "homebrew" then {
			homebrew.casks = [ "alacritty" ];
		} else {
			home.packages = [ pkgs.alacritty ];
		})
	];
}
