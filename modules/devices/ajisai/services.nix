{ repo, ... }:
{
	imports = [
		repo.server
		./services/opencloud.nix
		./services/openssh.nix
		./services/tailscale.nix
	];

	config = {
		pkgs.server.acme.domainNames = [ "khinenw.tk" "nenw.moe" "nenw.dev" ];
		pkgs.server.firewall.zones = {
			uplink = { interfaces = [ "ens3" ]; };
			podman = { interfaces = [ "podman*" ]; };
			tailscale = { interfaces = [ "tailscale*" ]; };
		};
	};
}
