{ lib, config, ... }:
{
	options = with lib.types; {
		pkgs.server.ingress = {
			rules = lib.mkOption {
				type = attrs;
				default = {};
				description = "virtual host rules for ingress";
			};
		};
	};

	config = let
		opts = config.pkgs.server.ingress;
	in {
		# Service
		services.nginx = {
			enable = true;
			recommendedGzipSettings = true;
			recommendedOptimisation = true;
			recommendedProxySettings = true;
			recommendedTlsSettings = true;

			virtualHosts = {
				"localhost" = {
					default = true;
					forceSSL = true;
					useACMEHost = "localhost";
					locations."/".extraConfig = ''
						return 404;
					'';
				};
			} // (
				lib.mapAttrs (name: value: lib.mkMerge [
					{ forceSSL = true; }
					(lib.mkIf (value ? "acmeHost") { useACMEHost = value.acmeHost; })
					(lib.mkIf (!(value ? "acmeHost")) { enableACME = true; })
					(lib.mkIf (value ? "proxyPort") {
						locations."/" = {
							proxyPass = "http://127.0.0.1:${toString value.proxyPort}/";
						};
					})
					(removeAttrs value ["proxyPort" "acmeHost"])
				]) opts.rules
			);
		};

		# Firewall
		pkgs.server.firewall.rules.ingress = {
			from = [ "all" ];
			allowedTCPPorts = [ 80 443 ];
		};
	};
}
