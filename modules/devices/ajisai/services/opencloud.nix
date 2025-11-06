{ ... }:
{
	config = {
		pkgs.server = {
			# Service
			podman.services.opencloud.enable = true;

			# Ingress
			ingress.rules."cloud.nenw.dev" = {
				acmeHost = "nenw.dev";
				proxyPort = 20618;
			};
		};
	};
}
