{ repo, ... }:
{
	imports = [
		repo.server
		./services/openssh.nix
		./services/tailscale.nix
	];

	config = {
		pkgs.server.acme.enable = false;
		pkgs.server.ingress.enable = false;
		pkgs.server.podman.enable = false;
		pkgs.server.firewall.enable = false;
		pkgs.server.firewall.zones = {
			uplink = { interfaces = [ "eno0" ]; };
			podman = { interfaces = [ "podman*" ]; };
			tailscale = { interfaces = [ "tailscale*" ]; };
		};
	};
}
