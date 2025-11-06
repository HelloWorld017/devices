{ lib, config, inputs, ... }:
{
	options = with lib.types; {
		pkgs.server.acme = {
			enable = lib.mkOption {
				type = bool;
				default = true;
			};

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

	config = let
		opts = config.pkgs.server.acme;
		secrets = config.age.secrets;
	in lib.mkIf opts.enable {
		age.secrets."cloudflare-dns-secret" = {
			file = "${inputs.self}/secrets/cloudflare-dns-secret.age";
		};

		users.users.nginx = {
			extraGroups = [ "acme" ];
		};

		security.acme = {
			acceptTerms = true;
			defaults.email = opts.email;
			certs = lib.genAttrs opts.domainNames (domain: {
				dnsProvider = "cloudflare";
				dnsResolver = "1.1.1.1:53";
				credentialFiles = {
					CLOUDFLARE_DNS_API_TOKEN_FILE = secrets.cloudflare-dns-secret.path;
				};
				dnsPropagationCheck = true;
				extraDomainNames = [ ("*." + domain) ];
				renewInterval = "weekly";
				reloadServices = [ "nginx" ] ++ opts.reloadedServices;
			});

		};

		systemd.services."acme-localhost".enable = lib.mkForce false;
	};
}
