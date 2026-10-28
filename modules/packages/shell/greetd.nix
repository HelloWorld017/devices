{ pkgs, lib, config, ... }:
let
  cfg = config.pkgs.shell.greeter;
  wallpaperDirectory = config.pkgs.shell.wallpaper.directory;
  greeterConfig = pkgs.writeText "greeter-config.json" (builtins.toJSON {
    user = config.constants.user;
    wallpaper = if cfg.wallpaper == null then "" else "file:///run/quickshell-greeter/wallpaper";
    session = [
      (lib.getExe config.programs.uwsm.package)
      "start" "-F" "--" "hyprland.desktop"
    ];
  });
  greeter = pkgs.writeShellScript "quickshell-greeter" ''
    export QT_QPA_PLATFORM=wayland
    export QT_QUICK_CONTROLS_STYLE=Basic
    unset QT_STYLE_OVERRIDE QT_QPA_PLATFORMTHEME
    export GREETER_CONFIG=${greeterConfig}
    ${lib.getExe pkgs.quickshell} --path ${./assets/greeter.qml}
    # Release the greeter compositor before greetd starts the user's session.
    ${pkgs.sway-unwrapped}/bin/swaymsg exit
  '';
  compositorConfig = pkgs.writeText "greeter-sway.conf" ''
    xwayland disable
    output * bg #101018 solid_color
    output * scale ${toString config.pkgs.shell.hyprland.scale}
    input * {
      xkb_layout us
      xkb_numlock enabled
      repeat_delay 300
      repeat_rate 40
    }
    seat * hide_cursor 5000
    exec ${greeter}
  '';
in {
  options.pkgs.shell.greeter.wallpaper = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = if wallpaperDirectory == null then null else "${wallpaperDirectory}/default.png";
    description = "Wallpaper copied at greeter startup; null uses a dark background.";
  };

  config = {
    services.greetd = {
      enable = true;
      settings.default_session.command = "${pkgs.sway-unwrapped}/bin/sway --config ${compositorConfig}";
    };

    # Copy as root so the greeter never needs access to the user's home.
    # A missing wallpaper (e.g. an encrypted home) falls back to a solid color.
    systemd.services.greetd = {
      serviceConfig.RuntimeDirectory = "quickshell-greeter";
      preStart = lib.optionalString (cfg.wallpaper != null) ''
        rm -f /run/quickshell-greeter/wallpaper
        if [ -f ${lib.escapeShellArg cfg.wallpaper} ]; then
          ${pkgs.coreutils}/bin/install -m 0644 ${lib.escapeShellArg cfg.wallpaper} /run/quickshell-greeter/wallpaper
        fi
      '';
    };
  };
}
