{ options, lib, pkgs, ... }:

{
	config = lib.mkMerge [
		(if options.fonts ? "fontconfig" then
			let
				fontConfig = {
					enable = true;
					defaultFonts = {
						serif = [ "Pretendard JP" ];
						sansSerif = [ "Pretendard JP" ];
						monospace = [ "Sarasa Term K Nerd Font" ];
					};
				};
			in {
				fonts.fontconfig = fontConfig;
				home.fonts.fontconfig = fontConfig;
			}
		else {})
		{
			fonts.fontDir.enable = true;
			fonts.packages = with pkgs; [
				(pkgs.callPackage ./aquatico.nix {})
				# (pkgs.callPackage ./geologica.nix {})
				(pkgs.callPackage ./sarasa-gothic.nix {})
				(pkgs.callPackage ./metropolis.nix {})
				(pkgs.callPackage ./nothing5x7.nix {})
				geist-font
				twemoji-color-font
				pretendard
				pretendard-jp
			];
		}
	];
}
