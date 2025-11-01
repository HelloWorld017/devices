{ ... }:
{
	config = {
		pkgs.server = {
			# Service
			podman.services.auth.enable = true;

			# Ingress
			ingress.rules."auth.nenw.dev" = {
				acmeHost = "nenw.dev";
				proxyPort = 20621;
			};
		};
	};
}
