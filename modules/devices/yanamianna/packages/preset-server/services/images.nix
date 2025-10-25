{ ... }:
{
	config = {
		# Service
		yanamianna.podmanServices.images.enable = true;

		# Ingress
		yanamianna.ingressRules."images.nenw.dev" = {
			acmeHost = "nenw.dev";
			proxyPort = 20622;
		};
	};
}
