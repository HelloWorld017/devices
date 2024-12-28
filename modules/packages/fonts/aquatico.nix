{ lib, fetchzip }:

let
	version = "1.0";
in fetchzip {
	name = "aquatico-${version}";

	url = "https://font.download/dl/font/aquatico.zip";
	sha256 = "sha256-WKdtQWyFnWr12TA1XNogGJDOO8Q4HdZHH6D8pZsf/x0=";
	stripRoot = true;

	postFetch = ''
		mkdir -p $out/share/fonts/truetype
		mv $out/*.otf -t $out/share/fonts/truetype
	'';

	meta = with lib; {
		description = "Aquatico Display Typeface";
		homepage = "https://font.download/font/aquatico";
		license = licenses.unfree;
		platforms = platforms.all;
	};
}

