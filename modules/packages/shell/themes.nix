{ pkgs, ... }:
{
	imports = [
		./kvantum.nix
	];

	config = {
		home.gtk = {
			enable = true;
			theme = {
				name = "WhiteSur-Dark";
				package = pkgs.whitesur-gtk-theme;
			};

			iconTheme = {
				name = "Colloid";
				package = pkgs.colloid-icon-theme;
			};
		};

		home.qt = {
			enable = true;
			platformTheme.name = "qtct";
			style.name = "kvantum";
		};

		pkgs.shell.kvantum = {
			name = "Utterly-Nord-Solid";
			package = (pkgs.callPackage ./kvantum-utterly-nord.nix {});
		};
	};
}
