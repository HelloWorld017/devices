{ ... }:
{
	config = {
		# Ingress
		yanamianna.ingressRules."cuttingedge.nenw.dev" = {
			acmeHost = "nenw.dev";
			proxyPort = 8080;
		};
	};
}
