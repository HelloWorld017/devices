{ ... }:
{
	config = {
		# Firewall
		yanamianna.firewallRules.mailserver = {
			from = "all";
			to = [ "out" ];
			allowedTCPPorts = [ 25 110 143 587 993 995 ];
		};

		# Acme
		yanamianna.acmeDomainNames = [ "mail-internal.nenw.dev" ];
	};
}
