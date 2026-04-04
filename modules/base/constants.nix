{ lib, config, ... }:
{
	options = with lib; with types; {
		constants = mkOption {
			device = mkOption {
				type = str;
			};

			user = mkOption {
				type = str;
				default = "nenw";
				description = "User name";
			};
		};
	};

	config = {
		constants.host = "${config.constants.user}-${config.constants.device}";
		networking.hostName = config.constants.host;
	};
}
