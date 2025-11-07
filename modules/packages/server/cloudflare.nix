{ lib, config, pkgs, ... }:
{
	options = {
		pkgs.server.firewall.cloudflare = with lib.types; {
			enable = lib.mkOption {
				type = bool;
				default = false;
			};

			uplinkZone = lib.mkOption {
				type = str;
				default = "uplink";
			};
		};
	};

	config = let
		opts = config.pkgs.server.firewall.cloudflare;
		fetchIPs = url: lib.filter (s: s != "") (
			lib.splitString "\n" (builtins.readFile (pkgs.fetchurl url))
		);
	in lib.mkIf opts.enable {
		pkgs.server.firewall = {
			sets.cloudflare-ips-v4 = {
				type = "ipv4_addr";
				flags = ["interval"];
				elements = fetchIPs {
					name = "cloudflare-ips-v4";
					url = "https://www.cloudflare.com/ips-v4/";
					sha256 = "sha256-8Cxtg7wBqwroV3Fg4DbXAMdFU1m84FTfiE5dfZ5Onns=";
				};
			};

			sets.cloudflare-ips-v6 = {
				type = "ipv6_addr";
				flags = ["interval"];
				elements = fetchIPs {
					name = "cloudflare-ips-v6";
					url = "https://www.cloudflare.com/ips-v6/";
					sha256 = "sha256-np054+g7rQDE3sr9U8Y/piAp89ldto3pN9K+KCNMoKk=";
				};
			};

			zones.cloudflare-v4 = lib.mkIf (opts.uplinkZone != null) {
				parent = opts.uplinkZone;
				ingressExpression = [ "ip saddr @cloudflare-ips-v4" ];
				egressExpression = [ "ip daddr @cloudflare-ips-v4" ];
			};

			zones.cloudflare-v6 = lib.mkIf (opts.uplinkZone != null) {
				parent = opts.uplinkZone;
				ingressExpression = [ "ip6 saddr @cloudflare-ips-v6" ];
				egressExpression = [ "ip6 daddr @cloudflare-ips-v6" ];
			};

			zoneAliases.cloudflare = [ "cloudflare-v4" "cloudflare-v6" ];
		};
	};
}
