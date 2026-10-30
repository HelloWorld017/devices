{ pkgs, lib, config, ... }:
let
  opts = config.pkgs.shell;
  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua {};
in
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) float;
  in {
    pkgs.shell.execOnce = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Commands spawned once on Hyprland startup, in declaration order.";
    };

    pkgs.shell.env = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Environment variables set by Hyprland.";
    };

    pkgs.shell.hyprland = {
      scale = mkOption {
        type = float;
        default = 1.5;
        description = "Scale of display";
      };
    };
  };

  config = {
    pkgs.shell.env = let
      cursorSize = toString (builtins.ceil (16 * opts.hyprland.scale));
    in {
      # Nixpkgs handles QT_QPA_PLATFORM; some applications need XWayland.
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_SCALE = builtins.toJSON opts.hyprland.scale;
      XCURSOR_SIZE = cursorSize;
      HYPRCURSOR_SIZE = cursorSize;
    };

    # TODO(nixpkgs/hyprland57): Update eyecandies
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    home.wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      configType = "lua";
      settings = {
        config = {
          general = {
            gaps_out = 12;
            border_size = 3;
            resize_on_border = true;
            col = {
              inactive_border = "rgba(ffffff30)";
              active_border = "rgba(ffffffa0)";
              nogroup_border = "rgba(ffffff30)";
              nogroup_border_active = "rgba(ffffffa0)";
            };
          };

          decoration = {
            rounding = 15;

            shadow = {
              enabled = true;
              range = 8;
              render_power = 2;
              color = "rgba(00000040)";
              color_inactive = "rgba(00000000)";
            };

            blur = {
              enabled = true;
              size = 12;
              passes = 1;
              vibrancy = 0.1696;
            };
          };

          group = {
            groupbar = {
              render_titles = false;
              rounding = 4;
              indicator_height = 3;
              col = {
                active = "rgba(ffffffa0)";
                inactive = "rgba(ffffff30)";
                locked_active = "rgba(303030ff)";
                locked_inactive = "rgba(30303080)";
              };
              gaps_in = 16;
              gaps_out = 8;
            };

            col = {
              border_inactive = "rgba(ffffff30)";
              border_active = "rgba(ffffffa0)";
            };
          };

          input = {
            repeat_rate = 40;
            repeat_delay = 300;
            follow_mouse = 2;
            float_switch_override_focus = 0;
            numlock_by_default = true;

            touchpad = {
              disable_while_typing = false;
            };
          };

          xwayland = {
            force_zero_scaling = true;
          };

          misc = {
            anr_missed_pings = 20;
            disable_hyprland_logo = true;
          };
        };

        env = lib.mapAttrsToList (name: value: { _args = [ name value ]; }) opts.env;
        on = lib.optional (opts.execOnce != []) {
          _args = [
            "hyprland.start"
            (mkLuaInline ''
              function()
              ${lib.concatMapStringsSep "\n" (command: "  hl.exec_cmd(${toLua command})") opts.execOnce}
              end
            '')
          ];
        };

        workspace_rule = [
          { workspace = "w[tv1]s[false]"; gaps_out = 0; gaps_in = 0; }
          { workspace = "f[1]s[false]"; gaps_out = 6; gaps_in = 0; }
        ];

        window_rule = [
          { match = { float = false; workspace = "w[tv1]s[false]"; }; border_size = 0; rounding = 0; }
          { match = { float = false; workspace = "f[1]s[false]"; }; rounding = 6; }
          { match.workspace = "10"; float = true; }
          { match.fullscreen = true; border_color = "rgb(5e81ac) rgb(d8dee9)"; }
          { match.class = "^(xdg-desktop-portal-gtk)$"; float = true; }
          { match.class = "^(praat)$"; float = true; }
          { match.class = "^(it.catboy.ripdrag)$"; pin = true; }
          { match.class = "^(better_control.py)$"; float = true; size = "1024 600"; }
        ];
      };

      plugins = with pkgs.hyprlandPlugins; [
        hy3
      ];
    };

    home.packages = with pkgs; [
      hyprpicker
    ];
  };
}
