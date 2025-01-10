{ options, lib, pkgs, ... }:

{
	config = lib.mkMerge [
		(if options.fonts ? "fontconfig" then {
			fonts.fontconfig = {
				enable = true;
				defaultFonts = {
					serif = [ "Pretendard JP" ];
					sansSerif = [ "Pretendard JP" ];
					monospace = [ "Sarasa Term K Nerd Font" ];
				};
			};
		} else {})
		{
			fonts.fontDir.enable = true;
			fonts.packages = with pkgs; [
				(pkgs.callPackage ./aquatico.nix {})
				(pkgs.callPackage ./sarasa-gothic.nix {})
				(pkgs.callPackage ./metropolis.nix {})
				geist-font
				pretendard
				pretendard-jp
			];
		}
	];
}
