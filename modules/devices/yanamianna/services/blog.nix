{ ... }:
{
	config = {
		pkgs.server = {
			# Service
			podman.services.blog.enable = true;

			# Ingress
			ingress.rules."blog.nenw.dev" = {
				acmeHost = "nenw.dev";
				proxyPort = 20619;
			};

			ingress.rules."kaede.nenw.dev" = {
				acmeHost = "nenw.dev";
				proxyPort = 20620;
			};
		};
	};
}
