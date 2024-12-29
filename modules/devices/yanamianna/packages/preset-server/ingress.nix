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
			recommendedGzipSettings = true;
			recommendedOptimisation = true;
			recommendedProxySettings = true;
			recommendedTlsSettings = true;

			virtualHosts = lib.mapAttrs (name: value: lib.mkMerge [
				{
					forceSSL = true;
				}
				(lib.mkIf (value ? "acmeHost") {
					useACMEHost = value.acmeHost;
				})
				(lib.mkIf (!(value ? "acmeHost")) {
					enableACME = true;
				})
				(lib.mkIf (value ? "proxyPort") {
					locations."/" = {
						proxyPass = "http://127.0.0.1:${toString value.proxyPort}/";
					};
				})
				(removeAttrs value ["proxyPort" "acmeHost"])
			]) config.yanamianna.ingressRules;
		};

		# Firewall
		yanamianna.firewallRules.ingress = {
			from = "all";
			to = [ "out" ];
			allowedTCPPorts = [ 80 443 ];
		};
	};
}
