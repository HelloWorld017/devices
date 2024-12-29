{ lib, config, ... }:
{
	options = with lib.types; {
		yanamianna = {
			acmeChallengeRoot = lib.mkOption {
				type = str;
				default = "/var/lib/acme/.challenges";
				description = "challenge root for acme";
			};

			acmeDomainNames = lib.mkOption {
				type = listOf str;
				default = [];
				description = "domain names for acme challenge";
			};
		};
	};

	config = {
		services.nginx = {
			virtualHosts = {
				"asterisk.nenw.dev" = {
					serverAliases = [ "*.nenw.dev" ];

					locations."/.well-known/acme-challenge" = {
						root = config.yanamianna.acmeChallengeRoot;
					};

					locations."./" = {
						return = "301 https://$host$request_uri";
					};
				};
			};
		};

		users.users.nginx = {
			extraGroups = [ "acme" ];
		};

		security.acme = {
			acceptTerms = true;
			defaults.email = "khi@nenw.dev";
			certs."nenw.dev" = {
				domain = "asterisk.nenw.dev";
				webroot = config.yanamianna.acmeChallengeRoot;
				extraDomainNames = config.yanamianna.acmeDomainNames;
			};
		};
	};
}
