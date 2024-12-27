{ stdenvNoCC, fetchFromGitHub, lib }:
stdenvNoCC.mkDerivation {
	pname = "fcitx5-fluent";
	version = "unstable-2024-12-26";

	src = fetchFromGitHub {
		owner = "Reverier-Xu";
		repo = "Fluent-fcitx5";
		rev = "b46d609b77f2e6ca01605d48fb452fa453a5e9ab";
		hash = "sha256-tVPp6kFgsWlSLcEUffOvXCWDEV0y7qcSqYKQkGO7lrM=";
	};

	installPhase = ''
		runHook preInstall

		mkdir -pv $out/share/fcitx5/themes/
		cp -rv Fluent* $out/share/fcitx5/themes/

		runHook postInstall
	'';

	meta = with lib; {
		description = "the fluent fcitx5 theme";
		homepage = "https://github.com/Reverier-Xu/Fluent-fcitx5";
		license = licenses.mpl20;
		platforms = platforms.all;
	};
}
