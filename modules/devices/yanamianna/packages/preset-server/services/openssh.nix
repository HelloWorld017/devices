{ ... }:
{
	config = {
		# Service
		services.openssh = {
			enable = true;
			ports = [ 37089 ];
			settings = {
				PasswordAuthentication = false;
				UseDns = true;
				X11Forwarding = false;
				PermitRootLogin = "no";
			};
		};

		# Firewall
		networking.nftables.firewall.rules = {
			ssh = {
				from = [ "local" ];
				to = [ "out" ];
				allowedTCPPorts = [ 37089 ];
			};
		};
	};
}
