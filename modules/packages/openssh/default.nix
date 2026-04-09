{ ... }:
{
	config = {
		services.openssh = {
			enable = true;
			ports = [ 37089 ];
			openFirewall = false;
			settings = {
				PasswordAuthentication = false;
				KbdInteractiveAuthentication = false;
				UseDns = true;
				X11Forwarding = false;
				PermitRootLogin = "no";
			};
		};
	};
}
