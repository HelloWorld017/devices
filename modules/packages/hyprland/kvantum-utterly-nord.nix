{ stdenvNoCC, fetchFromGitHub, lib }:
stdenvNoCC.mkDerivation {
	pname = "kvantum-utterly-nord";
	version = "unstable-2025-09-27";

	src = fetchFromGitHub {
		owner = "HimDek";
		repo = "Utterly-Nord-Plasma";
		rev = "e513b4dfeddd587a34bfdd9ba6b1d1eac8ecadf5";
		hash = "sha256-moLgBFR+BgoiEBzV3y/LA6JZfLHrG1weL1+h8LN9ztA=";
	};

	installPhase = ''
		runHook preInstall

		mkdir -p $out/share/Kvantum/
		cp -r kvantum* $out/share/Kvantum/
		for name in $out/share/Kvantum/kvantum*; do
			newname="$(echo $name | sed 's/kvantum\([a-z-]*\)$/Utterly-Nord\1/')";
			newname="$(echo $newname | sed 's/-light/-Light/' | sed 's/-solid/-Solid/')";
			mv "$name" "$newname"
		done

		runHook postInstall
	'';

	meta = with lib; {
		description = "A Slick and Modern Global theme for KDE Plasma utilizing the Nord Color Palette with transparency and blur in UI";
		homepage = "https://github.com/HimDek/Utterly-Nord-Plasma";
		license = licenses.gpl2;
		platforms = platforms.all;
	};
}
