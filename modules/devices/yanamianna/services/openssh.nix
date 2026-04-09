{ repo, ... }:
{
	imports = [ repo.openssh ];
	config = {
		pkgs.server = {
			# Firewall
			firewall.rules.ssh = {
				from = [ "local" ];
				allowedTCPPorts = [ 37089 ];
			};
		};
	};
}
