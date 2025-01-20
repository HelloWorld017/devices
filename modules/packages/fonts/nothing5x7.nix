{ lib, fetchurl }:

let
	version = "r1";
in fetchurl {
	name = "nothing5x7-${version}";

	url = "https://github.com/HelloWorld017/nothing-style-calendar/raw/81f6a59614ba0ef35b122700d083777ff56fa21b/app/src/main/res/font/nothing_font.otf";
	sha256 = "sha256-rk8oONR/GRXGKimiW0eoenxJHUaqL2S0eAzwxGHCAo8=";

	recursiveHash = true;
	downloadToTemp = true;
	postFetch = ''
		mkdir -p $out/share/fonts/truetype
		mv $downloadedFile $out/share/fonts/truetype/Nothing5x7-Regular.otf
	'';

	meta = with lib; {
		description = "A recreation of the font used by the Nothing company. This one is the 5x7 version.";
		homepage = "https://fontstruct.com/fontstructions/show/2095104/nothing-font-5x7";
		license = licenses.unfree;
		platforms = platforms.all;
	};
}

