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

		pkgs.server = {
			# Firewall
			firewall.rules.ssh = {
				from = [ "tailscale" ];
				allowedTCPPorts = [ 37089 ];
			};
		};
	};
}
