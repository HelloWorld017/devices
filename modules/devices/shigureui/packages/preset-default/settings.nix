{ config, pkgs, ... }:
{
	boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.supportedFilesystems = [ "ntfs" ];
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "nenw-shigureui";
	networking.networkmanager.enable = true;

	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};

	hardware.bluetooth = {
		enable = true;
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

	programs.noisetorch.enable = true;
	services.blueman.enable = true;
	services.gnome.gnome-keyring.enable = true;
	services.upower.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
	};

	users.users.nenw = {
		isNormalUser = true;
		description = "nenw*";
		extraGroups = [
			"audio"
			"docker"
			"networkmanager"
			"wheel"
		];
		packages = [];
	};

	home.wayland.windowManager.hyprland.settings = {
		# monitor = [
			# "DP-2, preferred, auto, 1.5"
			# "HDMI-A-1, preferred, auto-left, 1.5"
		# ];

		device = [
			{
				name = "asup1208:00-093a:3011-touchpad";
				natural_scroll = true;
			}
		];
	};

	home.defaultApplications = let
		browser = [ "firefox.desktop" ];
		imageViewer = [ "org.gnome.Loupe.dekstop" ];
	in {
		"application/pdf" = browser;
		"image/svg+xml" = browser;
		"image/jpeg" = imageViewer;
	};

	system.stateVersion = "25.05";
}
