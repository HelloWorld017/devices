{ lib, fetchurl }:

let
	version = "685f38-r1";
in fetchurl {
	name = "geologica-${version}";

	url = "https://github.com/googlefonts/geologica/raw/685f38d7c9e86b0c8530204c97ddcaf6558dd17b/fonts/variable/Geologica%5BCRSV,SHRP,slnt,wght%5D.ttf";
	sha256 = "sha256-RVIQcv9DxyGkQVIl1XvlujMlIKNHQA3vWZawSJn0jfs=";

	recursiveHash = true;
	downloadToTemp = true;
	postFetch = ''
		mkdir -p $out/share/fonts/truetype
		mv $downloadedFile $out/share/fonts/truetype/Geologica-Variable.ttf
	'';

	meta = with lib; {
		description = "Geologica is grounded in the humanist genre, but leans assertively into geometric, constructed letterforms to find its stability.";
		homepage = "https://github.com/googlefonts/geologica";
		license = licenses.ofl;
		platforms = platforms.all;
	};
}

