{ lib, fetchzip }:

let
	version = "r8";
in fetchzip {
	name = "metropolis-${version}";

	url = "https://github.com/njugunagathere/Metropolis/archive/refs/tags/${version}.zip";
	sha256 = "sha256-w7zSR7kEKUxcba2qiF8tL/4Hi1+jb+JtbjSkxdV5sEQ=";
	stripRoot = true;

	postFetch = ''
		mkdir -p $out/share/fonts/truetype
		mv $out/TrueType/*.ttf -t $out/share/fonts/truetype
	'';

	meta = with lib; {
		description = "A modern, geometric typeface";
		homepage = "https://github.com/njugunagathere/Metropolis";
		license = licenses.ofl;
		platforms = platforms.all;
	};
}

