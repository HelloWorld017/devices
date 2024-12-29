{ ... }:
{
	config = {
		# Service
		yanamianna.podmanServices.blog.enable = true;

		# Ingress
		yanamianna.ingressRules."blog.nenw.dev" = {
			acmeHost = "nenw.dev";
			proxyPort = 20619;
		};

		yanamianna.ingressRules."kaede.nenw.dev" = {
			acmeHost = "nenw.dev";
			proxyPort = 20620;
		};
	};
}
