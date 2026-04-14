{ pkgs, latestPkgs, ... }:

let
  tuiSettings = {
    "input_submit" = "return";
    "input_newline" = "shift+return";
    "theme" = "cursor";
  };
in {
  config = {
    home.packages = [
      latestPkgs.opencode
    ];

    home.configFile = {
      "opencode/tui.json" = let
        json = pkgs.formats.json { };
      in {
        source = json.generate "tui.json" tuiSettings;
      };
    };
  };
}
