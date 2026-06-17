{ lib, config, ... }:
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) attrsOf listOf port str;
  in {
    pkgs.server.ports = {
      allocation = {
        basePort = mkOption {
          type = port;
          default = 20620;
        };

        names = mkOption {
          type = listOf str;
          default = [];
        };
      };

      ports = mkOption {
        type = attrsOf port;
        default = {};
      };
    };
  };

  config = let
    inherit (lib) imap0 length listToAttrs mkDefault nameValuePair unique;
    opts = config.pkgs.server.ports;
  in {
    assertions = [
      {
        assertion = (length opts.allocation.names) == (length (unique opts.allocation.names));
        message = "port allocation names are duplicated.";
      }
    ];

    pkgs.server.ports.ports =
      listToAttrs (imap0 (i: name:
        (nameValuePair name)
        (mkDefault (opts.allocation.basePort + i))
      ) opts.allocation.names);
  };
}
