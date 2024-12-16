{ config, pkgs, ... }:
{
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "nenw-yanamianna";
	networking.networkmanager.enable = true;

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

	services.xserver.xkb = {
		layout = "us";
		variant = "";
	};

	users.users.nenw = {
		isNormalUser = true;
		description = "nenw*";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [];
	};

	system.stateVersion = "24.11";
}
