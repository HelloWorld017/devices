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
			fonts.packages = with pkgs; [
				(pkgs.callPackage ./sarasa-gothic.nix {})
				(pkgs.callPackage ./metropolis.nix {})
				pretendard
				pretendard-jp
			];
		}
	];
}
