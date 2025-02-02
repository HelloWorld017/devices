{ ... }:
{
	config = {
		# Service
		yanamianna.podmanServices.auth.enable = true;

		# Ingress
		yanamianna.ingressRules."auth.nenw.dev" = {
			acmeHost = "nenw.dev";
			proxyPort = 20621;
		};
	};
}
