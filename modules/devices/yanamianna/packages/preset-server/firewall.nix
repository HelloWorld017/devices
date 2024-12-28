{ inputs, ... }:
{
	imports = [
		inputs.nnf.nixosModules.default
	];

	config = {
		networking.nftables.enable = true;
		networking.nftables.firewall = {
			enable = true;
			localZoneName = "out";

			# Zones
			zones = {
				uplink = { interfaces = [ "enp4s0" ]; };
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
				nnf-loopback.enable = true;
			};
		};
	};
}
