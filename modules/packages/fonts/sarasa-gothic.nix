{ lib, fetchzip }:

let
	version = "1.0.33-0";
in fetchzip {
	name = "sarasa-gothic-nerd-font-${version}";

	url = "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts/releases/download/v${version}/sarasa-term-k-nerd-font.zip";
	hash = "sha256-YTdcUevg59+3C5VePHsqSJu07t+wpqEWmOk9dwJV8D4=";
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

