{ ... }:
{
	config = {
		pkgs.server = {
			# Service
			podman.services.mailserver.enable = true;

			# Ingress
			ingress.rules."webmail.nenw.dev" = {
				acmeHost = "nenw.dev";
				proxyPort = 20618;
			};

			# Firewall
			firewall.rules.mailserver = {
				from = [ "all" ];
				allowedTCPPorts = [ 25 110 143 587 993 995 ];
			};

			# Acme
			acme.reloadServices = [ "service-mailserver" ];
		};
	};
}
