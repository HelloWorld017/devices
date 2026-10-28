{ pkgs, lib, config, ... }:
let
  wallpaperDirectory = config.pkgs.shell.wallpaper.directory;
  selector = pkgs.writeShellScriptBin "select-wallpaper" ''
    set -euo pipefail
    export LC_ALL=C
    DIRECTORY=${lib.escapeShellArg (if wallpaperDirectory == null then "" else wallpaperDirectory)}
    if (( $# > 0 )); then DIRECTORY=$1; fi
    [[ -d "$DIRECTORY" ]] || exit 0

    mapfile -d "" -t WALLPAPERS < <(
      ${pkgs.findutils}/bin/find "$DIRECTORY" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.bmp' -o -iname '*.webp' -o -iname '*.svg' \) -print0 \
        | ${pkgs.coreutils}/bin/sort -z
    )
    (( ''${#WALLPAPERS[@]} > 0 )) || exit 0

    # UTC Unix time, floored to a four-hour bucket. Both consumers use this
    # exact hash and byte-sorted file list, independent of their environment.
    BUCKET=$(( $( ${pkgs.coreutils}/bin/date +%s ) / 14400 ))
    HASH=$(printf '%s' "$BUCKET" | ${pkgs.coreutils}/bin/sha256sum)
    INDEX=$(( 16#''${HASH:0:8} % ''${#WALLPAPERS[@]} ))
    printf '%s\n' "''${WALLPAPERS[$INDEX]}"
  '';
in {
  options = let
    inherit (lib) mkOption types;
    inherit (types) nullOr str;
  in {
    pkgs.shell.wallpaper = {
      selector = mkOption {
        type = types.package;
        readOnly = true;
        default = selector;
        description = "Shared four-hour hash-based wallpaper selector.";
      };
      directory = mkOption {
        type = nullOr str;
        description = "Directory of wallpapers";
        default = null;
      };
    };
  };

  config = lib.mkIf (wallpaperDirectory != null) {
      home.configFile."hypr/scripts/wallpaper_roll.sh" = {
        text = ''
          #!${pkgs.bash}/bin/bash
          set -euo pipefail

          STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/hyprpaper"
          WALLPAPER=$(${lib.getExe selector})
          [[ -n "$WALLPAPER" ]] || exit 0
          if [[ -f "$STATE_DIR/current" ]] && [[ "$(< "$STATE_DIR/current")" == "$WALLPAPER" ]]; then
            # ExecStartPost must still set the image after hyprpaper restarts.
            [[ "''${1:-}" == "--force" ]] || exit 0
          fi

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

      home-manager.users.${config.constants.user}.systemd.user = {
        services.hyprpaper.Service.ExecStartPost =
          "${config.home.path}/.config/hypr/scripts/wallpaper_roll.sh --force";
        services.wallpaper-refresh = {
          Unit = {
            Description = "Apply the current four-hour wallpaper";
            Requisite = [ "hyprpaper.service" ];
            After = [ "hyprpaper.service" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${config.home.path}/.config/hypr/scripts/wallpaper_roll.sh";
          };
        };
        timers.wallpaper-refresh = {
          Unit = {
            Description = "Refresh wallpaper at four-hour UTC boundaries";
            PartOf = [ "hyprpaper.service" ];
          };
          Timer = {
            OnCalendar = "*-*-* 00/4:00:00 UTC";
            OnClockChange = true;
            Persistent = true;
          };
          Install.WantedBy = [ "hyprpaper.service" ];
        };
      };

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
