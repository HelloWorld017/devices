{ pkgs, lib, config, ... }:
{
	options = with lib.types; {
		pkgs.server.ingress = {
			enable = lib.mkOption {
				type = bool;
				default = true;
			};

			rules = lib.mkOption {
				type = attrs;
				default = {};
				description = "virtual host rules for ingress";
			};
		};
	};

	config = let
		opts = config.pkgs.server.ingress;
		selfSignedCert = (pkgs.runCommand
			"self-signed-cert"
			{ nativeBuildInputs = [ pkgs.openssl ]; }
			''
				mkdir -p $out
				openssl req -x509 -nodes \
					-newkey rsa:4096 \
					-keyout $out/privkey.pem \
					-out $out/fullchain.pem \
					-days 36500 \
					-subj "/CN=localhost" \
					-addext "subjectAltName = DNS:localhost,IP:127.0.0.1"

				chmod 644 $out/fullchain.pem
				chmod 600 $out/privkey.pem
			''
		);
	in lib.mkIf opts.enable {
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
					sslCertificate = "${selfSignedCert}/fullchain.pem";
					sslCertificateKey = "${selfSignedCert}/privkey.pem";
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
