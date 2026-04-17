{ lib, config, ... }:
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) nullOr str;
  in {
    pkgs.shell.wallpaper = {
      directory = mkOption {
        type = nullOr str;
        description = "Directory of wallpapers";
        default = null;
      };
    };
  };

  config =
    let
      wallpaperDirectory = config.pkgs.shell.wallpaper.directory;
    in lib.mkIf (wallpaperDirectory != null) {
      home.configFile."hypr/scripts/wallpaper_roll.sh" = {
        text = ''
          #! /usr/bin/env zsh

          CURRENT_WALL=$(hyprctl hyprpaper listloaded)
          WALLPAPER=$(find "${wallpaperDirectory}" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)

          hyprctl hyprpaper reload ,"$WALLPAPER"
        '';
        executable = true;
      };

      home.wayland.windowManager.hyprland.settings = {
        exec-once = [
          "hyprpaper"
          "~/.config/hypr/scripts/wallpaper_roll.sh"
        ];
      };

      home.services.hyprpaper = {
        enable = true;
        settings = {
          preload = ["${wallpaperDirectory}/default.png"];
          wallpaper = [", ${wallpaperDirectory}/default.png"];
        };
      };
    };
}
