{ ... }:
{
	services.nginx = {
		virtualHosts = {
			"acmechallenge.nenw.dev" = {
				serverAliases = [ "*.nenw.dev" ];

				locations."/.well-known/acme-challenge" = {
					root = "/var/lib/acme/.challenges";
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
			webroot = "/var/lib/acme/.challenges";
			extraDomainNames = [ "internal-mail.nenw.dev" ];
		};
	};
}
