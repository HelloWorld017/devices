{ ... }:
{
	config = {
		# Service
		yanamianna.podmanServices.gluetun.enable = true;

		# Firewall
		yanamianna.firewallRules.ssh = {
			from = [ "local" ];
			to = [ "out" ];
			allowedTCPPorts = [ 30021 ];
		};
	};
}
