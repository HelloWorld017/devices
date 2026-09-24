{ pkgs, inputs, system, lib, ... }:

let
  inherit (lib) listToAttrs map nameValuePair;

  stores = [ "~/.cargo/**" "~/.pnpm/**" "/nix/store/**" ];
  config = {
    autoupdate = false;
    snapshots = false;
    permissions = {
      external_directory = listToAttrs (map (dir: nameValuePair dir "allow") stores);
      edit = listToAttrs (map (dir: nameValuePair dir "deny") stores);
    };
  };

  tuiConfig = {
    "input_submit" = "return";
    "input_newline" = "shift+return";
    "theme" = "cursor";
  };
in {
  config = {
    home.packages = [
      inputs.llm-agents.packages.${system}.opencode
    ];

    home.configFile = let
      json = pkgs.formats.json { };
    in {
      "opencode/tui.json".source = json.generate "tui.json" tuiConfig;
      "opencode/opencode.json".source = json.generate "opencode.json" config;
    };
  };
}
