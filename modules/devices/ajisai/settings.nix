{ pkgs, inputs, ... }:
{
	boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.loader.efi = {
		canTouchEfiVariables = false;
		efiSysMountPoint = "/boot/efi";
	};

	boot.loader.grub = {
		enable = true;
		efiSupport = true;

		# ConoHa VPS (v2) does not support UEFI!
		device = "/dev/vda";
		efiInstallAsRemovable = true;
	};

	networking.hostName = "nenw-ajisai";
	networking.useNetworkd = true;

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
			(import "${inputs.self}/keys.nix").all;
	};

	system.stateVersion = "24.11";
}
