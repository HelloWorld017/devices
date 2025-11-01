{ inputs, lib, config, pkgs, ... }:
{
	imports = [
		inputs.nnf.nixosModules.default
	];

	options = with lib.types; {
		pkgs.server.firewall = {
			localAddresses = lib.mkOption {
				type = listOf str;
				default = [];
				description = "ip addresses for internal network";
			};

			uplinkInterfaces = lib.mkOption {
				type = listOf str;
				default = [ "enp4s0" ];
				description = "network interface name for uplink";
			};

			extraZones = lib.mkOption {
				type = listOf attrs;
				default = [];
			};

			rules = lib.mkOption {
				type = attrs;
				default = {};
			};

			ignoredTables = lib.mkOption {
				type = listOf str;
				default = [];
				description = "tables which will be ignored when service reloaded";
			};
		};
	};

	config = let
		opts = config.pkgs.server.firewall;
	in {
		networking.nftables.enable = true;
		networking.nftables.firewall = {
			enable = true;
			localZoneName = "out";

			# Zones
			zones = {
				uplink = { interfaces = opts.uplinkInterfaces; };
				lo = { interfaces = [ "lo" ]; };
				podman = { interfaces = [ "podman*" ]; };
				tailscale = { interfaces = [ "tailscale*" ]; };
				local = {
					parent = "uplink";
					ipv4Addresses = [ opts.localAddresses ];
				};
			} // opts.extraZones;

			# Snippets
			# > Use lean snippets
			snippets = {
				nnf-common.enable = false;

				nnf-default-stopRuleset.enable = true;
				nnf-conntrack.enable = true;
				nnf-drop.enable = true;
				nnf-icmp.enable = true;
				nnf-loopback.enable = true;
			};

			# FIXME nftable flushes podman rules
			rules = opts.firewallRules ++ [
				{
					from = [ "podman" ];
					to = "all";

				}
			];
		};
	};
}
