{ ... }:
{
	config = {
		# Service
		yanamianna.podmanServices.gluetun.enable = true;

		# Firewall
		yanamianna.firewallRules.gluetun = {
			from = [ "local" ];
			to = [ "out" ];
			allowedTCPPorts = [ 30021 ];
		};
	};
}
