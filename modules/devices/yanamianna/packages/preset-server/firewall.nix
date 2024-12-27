{ inputs }:
{
	imports = [
		inputs.nnf.nixosModules.default
	];

	config = {
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
		};
	};
}
