{ pkgs, lib, inputs, ... }:
{
	boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.loader.efi = {
		canTouchEfiVariables = true;
		efiSysMountPoint = "/boot/efi";
	};

	boot.loader.grub = {
		enable = true;
		efiSupport = true;
		device = "nodev";
	};

	networking.hostName = "nenw-ajisai";
	systemd.network.enable = true;

	time.timeZone = "Asia/Seoul";
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "ko_KR.UTF-8";
		LC_IDENTIFICATION = "ko_KR.UTF-8";
		LC_MEASUREMENT = "ko_KR.UTF-8";
		LC_MONETARY = "ko_KR.UTF-8";
		LC_NAME = "ko_KR.UTF-8";
		LC_NUMERIC = "ko_KR.UTF-8";
		LC_PAPER = "ko_KR.UTF-8";
		LC_TELEPHONE = "ko_KR.UTF-8";
		LC_TIME = "ko_KR.UTF-8";
	};

	users.users.nenw = {
		isNormalUser = true;
		description = "nenw*";
		extraGroups = [
			"wheel"
		];
		packages = [];
		openssh.authorizedKeys.keys =
			lib.attrValues (import "${inputs.self}/keys.nix");
	};

	system.stateVersion = "24.11";
}
