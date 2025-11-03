let
	keys = import ../keys.nix;
in {
	"cloudflare-dns-secret.age".publicKeys = keys.all;
	"openweatherapi-secret.age".publicKeys = keys.all;
}
