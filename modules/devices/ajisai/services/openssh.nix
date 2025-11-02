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
				from = [ "local" ];
				allowedTCPPorts = [ 37089 ];
			};
		};
	};
}
