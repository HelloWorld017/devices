{ lib, config, ... }:
{
  options = let
    inherit (lib) attrNames concatLists isAttrs isList map mkOption types;
    inherit (types) coercedTo lazyAttrsOf listOf oneOf port str;

    flattenAttrs = prefix: value:
      if isAttrs value then
        concatLists (
          map
            (innerKey: flattenAttrs (prefix ++ [ innerKey ]) value.${innerKey})
            (attrNames value)
        )
      else if isList value then map (item: prefix ++ [ item ]) value
      else throw "invalid port allocation name";

    allocationInput = oneOf [(listOf str) (lazyAttrsOf allocationInput)];
    allocationNames = coercedTo
      allocationInput
      (attrs: flattenAttrs [] attrs)
      (listOf (listOf str));

    portsOutput = lazyAttrsOf (oneOf [port portsOutput]);
  in {
    pkgs.server.ports = {
      allocation = {
        basePort = mkOption {
          type = port;
          default = 20620;
        };

        names = mkOption {
          type = allocationNames;
          default = [];
        };
      };

      ports = mkOption {
        type = portsOutput;
        default = {};
      };
    };
  };

  config = let
    inherit (lib) foldl' imap0 length mkDefault recursiveUpdate setAttrByPath unique;
    opts = config.pkgs.server.ports;
  in {
    assertions = [
      {
        assertion = (length opts.allocation.names) == (length (unique opts.allocation.names));
        message = "port allocation names are duplicated.";
      }
    ];

    pkgs.server.ports.ports = foldl' recursiveUpdate {} (imap0
      (i: path: setAttrByPath path (mkDefault (opts.allocation.basePort + i)))
      opts.allocation.names
    );
  };
}
