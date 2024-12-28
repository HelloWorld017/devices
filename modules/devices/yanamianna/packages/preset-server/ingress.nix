{ ... }:
{
	services.nginx = {
		enable = true;
	};

	networking.nftables.firewall.rules = {
		ingress = {
			from = "all";
			to = [ "out" ];
			allowedTCPPorts = [ 80 443 ];
		};
	};
}
