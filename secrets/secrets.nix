let
	keys = import ../keys.nix;
in {
	"openweatherapi-secret.age".publicKeys = [ keys.user-nenw-shigureui ];
}
