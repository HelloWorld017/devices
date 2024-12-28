{ ... }:
{
	config = {
		# Firewall
		networking.nftables.firewall.rules = {
			mailserver = {
				from = "all";
				to = [ "out" ];
				allowedTCPPorts = [ 25 110 143 587 993 995 ];
			};
		};
	};
}
