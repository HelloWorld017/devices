{ lib, config, ... }:
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) nullOr package str;
  in {
    pkgs.shell.kvantum = {
      name = mkOption {
        type = nullOr str;
        default = null;
      };

      package = mkOption {
        type = nullOr package;
        default = null;
      };
    };
  };

  config = let
    cfg = config.pkgs.shell.kvantum;
    themeName = cfg.name;
    theme = cfg.package;
  in {
    home.configFile."Kvantum/${themeName}" = lib.mkIf (themeName != null && theme != null) {
      source = "${theme}/share/Kvantum/${themeName}";
    };

    home.configFile."Kvantum/kvantum.kvconfig" = lib.mkIf (themeName != null) {
      text = ''
        [General]
        theme=${themeName}
      '';
    };
  };
}
