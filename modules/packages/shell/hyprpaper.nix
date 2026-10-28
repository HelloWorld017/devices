{ pkgs, lib, config, ... }:
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
          #!${pkgs.bash}/bin/bash
          set -euo pipefail

          STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/hyprpaper"
          CURRENT_WALL=${lib.escapeShellArg "${wallpaperDirectory}/default.png"}
          if [[ -f "$STATE_DIR/current" ]]; then
            IFS= read -r CURRENT_WALL < "$STATE_DIR/current" || true
          fi

          WALLPAPERS=()
          while IFS= read -r -d "" FILE; do
            if [[ "$FILE" != "$CURRENT_WALL" ]]; then
              WALLPAPERS+=("$FILE")
            fi
          done < <(${pkgs.findutils}/bin/find ${lib.escapeShellArg wallpaperDirectory} -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
            -o -iname '*.bmp' -o -iname '*.webp' -o -iname '*.svg' \) -print0)

          if (( ''${#WALLPAPERS[@]} == 0 )); then
            exit 0
          fi
          WALLPAPER="''${WALLPAPERS[RANDOM % ''${#WALLPAPERS[@]}]}"

          # The service can still be initializing its IPC socket on startup.
          for (( ATTEMPT=0; ATTEMPT<50; ATTEMPT++ )); do
            if ${config.programs.hyprland.package}/bin/hyprctl hyprpaper wallpaper ",$WALLPAPER,cover"; then
              ${pkgs.coreutils}/bin/mkdir -p "$STATE_DIR"
              printf '%s\n' "$WALLPAPER" > "$STATE_DIR/current"
              exit 0
            fi
            ${pkgs.coreutils}/bin/sleep 0.1
          done
          exit 1
        '';
        executable = true;
      };

      home-manager.users.${config.constants.user}.systemd.user.services.hyprpaper.Service.ExecStartPost =
        "${config.home.path}/.config/hypr/scripts/wallpaper_roll.sh";

      home.services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          wallpaper = [
            {
              monitor = "";
              path = "${wallpaperDirectory}/default.png";
              fit_mode = "cover";
            }
          ];
        };
      };
    };
}
