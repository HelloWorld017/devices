{ lib, fetchzip }:

let
	version = "0.37.4-1";
in fetchzip {
	name = "sarasa-gothic-nerd-font-${version}";

	url = "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts/releases/download/v${version}/sarasa-term-k-nerd-font.zip";
	sha256 = "6c7a4b7a0b70cba42801f6bc8cf127cc5a349ebacd35871802e4c2f30f9b64ea";
	stripRoot = false;

	postFetch = ''
		mkdir -p $out/share/fonts/truetype
		mv $out/*.ttf -t $out/share/fonts/truetype
	'';

	meta = with lib; {
		description = "Nerd font fetched SarasaGothic";
		homepage = "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts";
		license = licenses.ofl;
		platforms = platforms.all;
	};
}

