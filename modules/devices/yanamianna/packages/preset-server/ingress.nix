{ lib, config, ... }:
{
	options = with lib.types; {
		yanamianna = {
			ingressRules = lib.mkOption {
				type = attrs;
				default = {};
				description = "virtual host rules for ingress";
			};
		};
	};

	config = {
		# Service
		services.nginx = {
			enable = true;
			virtualHosts = config.yanamianna.ingressRules;
		};

		# Firewall
		yanamianna.firewallRules.ingress = {
			from = "all";
			to = [ "out" ];
			allowedTCPPorts = [ 80 443 ];
		};
	};
}
