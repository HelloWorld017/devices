{ inputs, ... }:
{
	wsl.defaultUser = "nenw";

	networking.hostName = "nenw-akebi";

	users.users.nenw = {
		isNormalUser = true;
		description = "nenw*";
		group = "nenw";
		extraGroups = [];
		packages = [];
		openssh.authorizedKeys.keys =
			(import "${inputs.self}/keys.nix").all;
	};

	users.groups.nenw = {};

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
