{ config, lib, pkgs, ... }:

{
	config = {
		fonts.packages = with pkgs; [
			(pkgs.callPackage ./sarasa-gothic.nix {})
			(pkgs.callPackage ./metropolis.nix {})
			pretendard
			pretendard-jp
		];
	};
}
