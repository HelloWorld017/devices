{ stdenvNoCC, fetchFromGitHub, lib }:
stdenvNoCC.mkDerivation {
	pname = "fcitx5-candlelight";
	version = "unstable-2024-12-26";

	src = fetchFromGitHub {
		owner = "thep0y";
		repo = "fcitx5-themes-candlelight";
		rev = "d4146d3d3f7a276a8daa2847c3e5c08de20485da";
		hash = "sha256-/IdN69izB30rl1gswsXivYtpAeCUdahP7oy06XJXo0I=";
	};

	installPhase = ''
		runHook preInstall

		mkdir -pv $out/share/fcitx5/themes/
		cp -rv macOS-* $out/share/fcitx5/themes/

		runHook postInstall
	'';

	meta = with lib; {
		description = "the candlelight fcitx5 theme";
		homepage = "https://github.com/thep0y/fcitx5-themes-candlelight";
		license = licenses.mit;
		platforms = platforms.all;
	};
}
