{ pkgs, config, lib, ... }:
{
	options = with lib.types; {
		pkgs.nix-ld = {
			withPackages = lib.mkOption {
				type = bool;
				default = false;
			};
		};
	};

	config = let
		opts = config.pkgs.nix-ld;
	in {
		programs.nix-ld = {
			enable = true;
			libraries = lib.mkIf opts.withPackages (with pkgs; [
				# Essential
				stdenv.cc.cc.lib
				openssl
				zlib

				# Additional
				xorg.libX11
				libGL
				pipewire
			]);
		};
	};
}
