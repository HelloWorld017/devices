{ ... }:
{
	config = {
		pkgs.server = {
			# Ingress
			ingress.rules."cuttingedge.nenw.dev" = {
				acmeHost = "nenw.dev";
				proxyPort = 8080;
			};
		};
	};
}
