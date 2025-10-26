{ lib, config, inputs, ... }:
{
	options = with lib.types; {
		pkgs.server.acme = {
			email = lib.mkOption {
				type = str;
				default = "khi@nenw.dev";
				description = "email for the certificate";
			};

			domainNames = lib.mkOption {
				type = listOf str;
				default = [];
				description = "domain names to fetch";
			};

			reloadedServices = lib.mkOption {
				type = listOf str;
				default = [];
				description = "services which will be reloaded on acme renew";
			};
		};
	};

	config = {
		age.secrets."cloudflare-dns-secret" = {
			file = "${inputs.self}/secrets/cloudflare-dns-secret.age";
		};

		users.users.nginx = {
			extraGroups = [ "acme" ];
		};

		security.acme = {
			acceptTerms = true;
			preliminarySelfsigned = true;
			defaults.email = config.pkgs.server.acme.email;
			certs = lib.genAttrs config.pkgs.server.acme.domainNames (domain: {
				name = domain;
				value = {
					dnsProvider = "cloudflare";
					dnsResolver = "1.1.1.1:53";
					credentialFiles = {
						CLOUDFLARE_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare-dns-secret.path;
					};
					dnsPropagationCheck = true;
					extraDomainNames = [ ("*." + domain) ];
					renewInterval = "weekly";
					reloadServices = [ "nginx" ] ++ config.pkgs.server.acme.reloadedServices;
				};
			}) // {
				"localhost" = {
					server = "https://127.0.0.1/acme-failing";
					webroot = "/var/lib/acme/.challenges-failing";
					renewInterval = "yearly";
				};
			};

		};

		systemd.services."acme-localhost".enable = lib.mkForce false;
	};
}
