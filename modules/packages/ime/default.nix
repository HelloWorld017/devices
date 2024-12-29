{ pkgs, ... }:
{
	config = {
		i18n.inputMethod = {
			enable = true;
			type = "fcitx5";
			fcitx5.addons = with pkgs; [
				fcitx5-gtk
				fcitx5-mozc
				fcitx5-hangul
				fcitx5-fluent
				(callPackage ./fcitx5-candlelight.nix {})
			];
		};

		# fcitx5 settings
		home.configFile = {
			"fcitx5/config" = { text = (builtins.readFile ./assets/fcitx_config); force = true; };
			"fcitx5/profile" = { text = (builtins.readFile ./assets/fcitx_profile); force = true; };
			"fcitx5/conf/classicui.conf".text = (builtins.readFile ./assets/fcitx_classicui);
		};

		services.xserver.xkb = {
			layout = "ansi-korean";
			variant = "";
			options = "";
			extraLayouts.ansi-korean = {
				description = "ANSI layout with RAlt Hangul swap, CapsLock issue fix";
				languages = [ "eng" ];
				symbolsFile = ./assets/xkb_ansi_korean;
			};
		};

		# Workaround for theme issue
		# > Reference: NixOS/nixpkgs#264815
		environment.pathsToLink = [ "/share/fcitx5" ];

		# Because hyprland has different xkeyboard-config deps
		# > (extraLayouts does not work)
		home.configFile."xkb/symbols/ansi-korean".text = (builtins.readFile ./assets/xkb_ansi_korean);

		home.wayland.windowManager.hyprland = {
			settings = {
				input = {
					kb_layout = "ansi-korean";
					kb_variant = "";
					kb_options = "";
				};

				windowrule = [
					"pseudo, fcitx"
				];

				exec-once = [
					"fcitx5 -d -r"
					"fcitx5-remote -r"
				];
			};
		};
	};
}
