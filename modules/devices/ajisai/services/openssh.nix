{ repo, ... }:
{
	imports = [ repo.openssh ];

	config = {
		pkgs.server = {
			firewall.rules.ssh = {
				from = [ "tailscale" ];
				allowedTCPPorts = [ 37089 ];
			};
		};
	};
}
