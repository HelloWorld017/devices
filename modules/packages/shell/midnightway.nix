{ lib, config, inputs, system, ... }:
{
	options = with lib.types; {
		pkgs.shell.midnightway = {
			system = {
				gpuCard = lib.mkOption {
					type = nullOr str;
					default = "renderD128";
					description = "GPU Interface Name";
				};

				networkInterface = lib.mkOption {
					type = str;
					default = "wlo1";
					description = "Network Interface Name";
				};
			};
		};
	};

	config = {
		home.packages = [
			inputs.midnightway.packages.${system}.default
		];

		home.wayland.windowManager.hyprland.settings = {
			exec-once = [
				"midnightway &"
			];
		};

		home.configFile."midnightway/config.json".source = let
			mkOutOfStoreSymlink = config.home.lib.file.mkOutOfStoreSymlink;
			secretPath = config.age-template.files."midnightway-config.json".path;
		in (mkOutOfStoreSymlink secretPath);

		age.secrets."openweatherapi-secret" = {
			file = "${inputs.self}/secrets/openweatherapi-secret.age";
		};

		age-template.files."midnightway-config.json" = {
			owner = config.home.user;
			vars = {
				weather_api = config.age.secrets.openweatherapi-secret.path;
			};
			content = let
				opts = config.pkgs.shell.midnightway;
			in builtins.toJSON {
				locale = "ko-KR";
				bar = {
					autohide = true;
					status = {
						items = [
							{ kind = "network"; visibility = "full"; }
							{ kind = "battery"; visibility = "full"; }
							{ kind = "sound"; visibility = "default"; }
							{ kind = "temperature"; visibility = "default"; }
							{ kind = "performance"; visibility = "default"; }
						];
					};
				};
				weather = {
					location = "Daejeon, Korea";
					apiToken = "$weather_api";
				};
				system = {
					gpuCard = opts.system.gpuCard;
					networkInterface = opts.system.networkInterface;
				};
			};
		};
	};
}
