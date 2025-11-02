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

		pkgs.server = {
			# Firewall
			firewall.rules.tailscale = {
				from = [ "all" ];
				allowedUDPPorts = [ 41641 ];
			};

			firewall.rules.tailscale-exit-node = {
				from = [ "tailscale" ];
				to = [ "uplink" "tailscale" ];
				verdict = "accept";
			};
		};
	};
}
