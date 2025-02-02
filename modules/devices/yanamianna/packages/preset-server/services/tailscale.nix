{ ... }:
{
	config = {
		# Service
		services.tailscale = {
			enable = true;
			useRoutingFeatures = "server";
			extraSetFlags = [ "--advertise-exit-node" ];
			port = 41641;
		};

		# Firewall
		yanamianna.firewallRules.tailscale = {
			from = "all";
			to = "all";
			allowedUDPPorts = [ 41641 ];
		};
	};
}
