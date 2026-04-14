{ lib, config, ... }:
{
  options = with lib; with types; {
    constants = {
      device = mkOption {
        type = str;
      };

      user = mkOption {
        type = str;
        default = "nenw";
        description = "User name";
      };

      host = mkOption {
        type = str;
        default = "${config.constants.user}-${config.constants.device}";
      };
    };
  };

  config = {
    networking.hostName = config.constants.host;
  };
}
