{ ... }:
{
	config = {
		pkgs.server = {
			# Service
			podman.services.images.enable = true;

			# Ingress
			ingress.rules."images.nenw.dev" = {
				acmeHost = "nenw.dev";
				proxyPort = 20622;
			};
		};
	};
}
