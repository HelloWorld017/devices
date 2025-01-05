{ ... }:
{
	config = {
		# Service
		yanamianna.podmanServices.mailserver.enable = true;

		# Ingress
		yanamianna.ingressRules."webmail.nenw.dev" = {
			acmeHost = "nenw.dev";
			proxyPort = 20618;
		};

		# Firewall
		yanamianna.firewallRules.mailserver = {
			from = "all";
			to = "all";
			allowedTCPPorts = [ 25 110 143 587 993 995 ];
		};

		# Acme
		yanamianna.acmeReloadServices = [ "mailserver" ];
	};
}
