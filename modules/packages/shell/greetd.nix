{ pkgs, lib, config, ... }:
let
  cfg = config.pkgs.shell.greeter;
  wallpaperDirectory = config.pkgs.shell.wallpaper.directory;
  wallpaperMounts =
    lib.optional (wallpaperDirectory != null)
      "-${wallpaperDirectory}:/run/quickshell-greeter/wallpapers"
    ++ lib.optional (cfg.wallpaper != null)
      "-${cfg.wallpaper}:/run/quickshell-greeter/override";

  greeterConfig = pkgs.writeText "greeter-config.json" (builtins.toJSON {
    user = config.constants.user;
    wallpaperFile = "/run/quickshell-greeter/wallpaper-path";
    session = [
      (lib.getExe' pkgs.systemd "systemd-cat")
      "--identifier=uwsm"
      (lib.getExe config.programs.uwsm.package)
      "start" "-F" "--" "hyprland.desktop"
    ];
  });

  greeter = pkgs.writeShellScript "quickshell-greeter" ''
    export QT_QPA_PLATFORM=wayland
    export QT_QUICK_CONTROLS_STYLE=Basic
    export QT_SCALE_FACTOR=1
    export QT_FONT_DPI=96
    unset QT_STYLE_OVERRIDE QT_QPA_PLATFORMTHEME
    export GREETER_CONFIG=${greeterConfig}
    exec ${lib.getExe pkgs.quickshell} --path ${./assets/greeter.qml}
  '';

  prepareWallpaper = let
    wallpaper = if cfg.wallpaper != null then "/run/quickshell-greeter/override"
      else ''$(${lib.getExe config.pkgs.shell.wallpaper.selector} "$DIRECTORY/wallpapers")'';
  in pkgs.writeShellScript "prepare-greeter-wallpaper" ''
    set -euo pipefail
    DIRECTORY=/run/quickshell-greeter
    ${pkgs.coreutils}/bin/mkdir -p "$DIRECTORY"

    WALLPAPER=${wallpaper}
    SOURCE=""

    if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
      SOURCE=$(${lib.getExe pkgs.jq} -rn --arg path "$WALLPAPER" \
        '"file://" + ($path | split("/") | map(@uri) | join("/"))')
    fi

    printf '%s\n' "$SOURCE" > "$DIRECTORY/wallpaper-path.new"
    ${pkgs.coreutils}/bin/mv -f "$DIRECTORY/wallpaper-path.new" "$DIRECTORY/wallpaper-path"
  '';
in {
  options.pkgs.shell.greeter.wallpaper = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Fixed greeter wallpaper override; null selects from the shared wallpaper directory, or uses a dark background if none is available.";
  };

  config = {
    services.greetd = {
      enable = true;
      settings.default_session.command = "${lib.getExe' pkgs.systemd "systemd-cat"} --identifier=greeter ${lib.getExe pkgs.cage} -s -d -- ${greeter}";
    };

    systemd.services.greetd = {
      serviceConfig = {
        RuntimeDirectory = "quickshell-greeter";
        BindReadOnlyPaths = wallpaperMounts;
        StandardOutput = "journal";
        StandardError = "journal";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };
      preStart = "${prepareWallpaper}";
    };

    systemd.services.greeter-wallpaper = {
      description = "Prepare the current four-hour greeter wallpaper";
      after = [ "greetd.service" ];
      unitConfig.ConditionPathIsDirectory = "/run/quickshell-greeter";
      serviceConfig = {
        Type = "oneshot";
        BindReadOnlyPaths = wallpaperMounts;
        ExecStart = prepareWallpaper;
      };
    };

    systemd.timers.greeter-wallpaper = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 00/4:00:00 UTC";
        OnClockChange = true;
        Persistent = true;
      };
    };
  };
}
