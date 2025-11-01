{ repo, ... }:
{
	imports = [
		repo.server
		./services/auth.nix
		./services/cuttingedge.nix
		./services/blog.nix
		./services/gluetun.nix
		./services/images.nix
		./services/mailserver.nix
		./services/openssh.nix
		./services/tailscale.nix
	];

	config = {
		pkgs.server.firewall.zones = {
			uplink = { interfaces = [ "enp4s0" ]; };
			podman = { interfaces = [ "podman*" ]; };
			tailscale = { interfaces = [ "tailscale*" ]; };
			local = {
					parent = "uplink";
					ipv4Addresses = [ "192.168.25.0/24" ];
			};
		};
	};
}
