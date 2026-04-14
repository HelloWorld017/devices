{ pkgs, config, ... }:
{
	constants.device = "yanamianna";

	boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.supportedFilesystems = [ "ntfs" ];
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.networkmanager.enable = true;

	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};

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

	users.users.${config.constants.user} = {
		extraGroups = [
			"audio"
			"docker"
			"networkmanager"
			"wheel"
		];
	};

	system.stateVersion = "24.11";
}
