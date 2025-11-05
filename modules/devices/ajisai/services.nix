{ repo, ... }:
{
	imports = [
		repo.server
		./services/openssh.nix
		./services/tailscale.nix
	];

	config = {
		pkgs.server.acme.enable = true;
		pkgs.server.ingress.enable = true;
		pkgs.server.podman.enable = false;
		pkgs.server.firewall.enable = true;
		pkgs.server.firewall.zones = {
			uplink = { interfaces = [ "ens3" ]; };
			podman = { interfaces = [ "podman*" ]; };
			tailscale = { interfaces = [ "tailscale*" ]; };
		};
	};
}
