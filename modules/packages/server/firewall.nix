{ inputs, lib, config, ... }:
{
	imports = [
		inputs.nnf.nixosModules.default
	];

	options = with lib.types; {
		pkgs.server.firewall = {
			uplinkInterface = lib.mkOption {
				type = str;
				default = "enp4s0";
				description = "network interface name for uplink";
			};

			rules = lib.mkOption {
				type = attrs;
				default = {};
				description = "firewall rules";
			};

			ignoredTables = lib.mkOption {
				type = listOf str;
				default = [];
				description = "tables which will be ignored when service reloaded";
			};
		};
	};

	config = {
		networking.nftables.enable = true;
		networking.nftables.chains = let
			internalRule = {
				after = lib.mkForce ["veryEarly"];
				before = ["conntrack" "early"];
				rules = lib.singleton ''
					iifname { lo } accept
					iifname { podman* } accept
					iifname { tailscale* } accept
				'';
			};
		in {
			input.internal = internalRule;
			forward.internal = internalRule;
		};

		networking.nftables.firewall = {
			enable = true;
			localZoneName = "out";

			# Zones
			zones = {
				uplink = { interfaces = [ "enp4s0" ]; };
				podman = { interfaces = [ "podman*" ]; };
				local = {
					parent = "uplink";
					ipv4Addresses = [ "192.168.25.0/24" ];
				};
			};

			# Snippets
			# > Use lean snippets
			snippets = {
				nnf-common.enable = false;
				nnf-default-stopRuleset.enable = true;

				nnf-conntrack.enable = true;
				nnf-drop.enable = true;
				nnf-icmp.enable = true;
			};

			# FIXME nftable flushes podman rules
			rules = config.yanamianna.firewallRules;
		};
	};
}
