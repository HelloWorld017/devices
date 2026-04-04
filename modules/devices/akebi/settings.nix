{ config, ... }:
{
	networking.hostName = "nenw-akebi";

	users.users.${config.home.user} = {
		group = "nenw";
		extraGroups = [ "users" ];
	};

	wsl.defaultUser = config.home.user;

	virtualisation.podman = {
		enable = true;
		autoPrune = {
			enable = true;
			dates = "weekly";
			flags = ["--all"];
		};

		defaultNetwork.settings = {
			dns_enabled = true;
		};
	};

	services.openssh = {
		enable = true;
		ports = [ 37089 ];
		settings = {
			PasswordAuthentication = false;
			UseDns = true;
			X11Forwarding = false;
			PermitRootLogin = "no";
		};
	};

	pkgs.wsl.nvidia.enable = true;

	system.stateVersion = "24.11";
}
