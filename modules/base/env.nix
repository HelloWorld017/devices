{ lib, config, ... }:
{
  options = let
    inherit (lib) concatMapStringsSep isList mapAttrs mkOption types;
    inherit (types) attrsOf either listOf oneOf str path;
  in {
    env = mkOption {
      type = attrsOf (oneOf [ str path (listOf (either str path)) ]);
      apply = mapAttrs (n: v:
        # Handle an array of items separated by `:` e.g. PATH.
        if isList v then
          concatMapStringsSep ":" (x: toString x) v
        else
          (toString v));

      default = {};
      description = "Global environment variables";
    };
  };

  config = let
    inherit (lib) concatStringsSep mapAttrsToList;
  in {
    env.PATH = ["$PATH"];

    # Writing Environments
    environment.extraInit = concatStringsSep "\n"
      (mapAttrsToList (n: v: ''export ${n}="${v}"'') config.env);
  };
}
