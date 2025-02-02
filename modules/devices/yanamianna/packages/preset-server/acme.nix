{ lib, config, ... }:
{
	options = with lib.types; {
		yanamianna = {
			acmeReloadServices = lib.mkOption {
				type = listOf str;
				default = [];
				description = "services which will be reloaded on acme renew";
			};
		};
	};

	config = {
		users.users.nginx = {
			extraGroups = [ "acme" ];
		};

		security.acme = {
			acceptTerms = true;
			preliminarySelfsigned = true;
			defaults.email = "khi@nenw.dev";
			certs."nenw.dev" = {
				dnsProvider = "cloudflare";
				dnsResolver = "1.1.1.1:53";
				credentialFiles = {
					CLOUDFLARE_DNS_API_TOKEN_FILE = "/var/lib/acme/.secrets/cloudflare";
				};
				dnsPropagationCheck = true;
				extraDomainNames = [ "*.nenw.dev" ];
				renewInterval = "weekly";
				reloadServices = [ "nginx" ] ++ config.yanamianna.acmeReloadServices;
			};

			certs."localhost" = {
				server = "https://127.0.0.1/acme-failing";
				webroot = "/var/lib/acme/.challenges-failing";
				renewInterval = "yearly";
			};
		};

		systemd.services."acme-localhost".enable = lib.mkForce false;
	};
}
