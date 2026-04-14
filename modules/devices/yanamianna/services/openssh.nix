{ repo, ... }:
{
	imports = [ repo.openssh ];
	config = {
		pkgs.server = {
			# Firewall
			firewall.rules.ssh = {
				from = [ "local" "tailscale" ];
				allowedTCPPorts = [ 37089 ];
			};
		};
	};
}
