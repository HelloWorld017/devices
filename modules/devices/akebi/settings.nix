{ ... }:
{
	wsl.defaultUser = "nenw";

	networking.hostName = "nenw-akebi";

	users.users.nenw = {
		isNormalUser = true;
		description = "nenw*";
		group = "nenw";
		extraGroups = [];
		packages = [];
	};

	users.groups.nenw = {};

	pkgs.wsl.nvidia.enable = true;

	system.stateVersion = "24.11";
}
