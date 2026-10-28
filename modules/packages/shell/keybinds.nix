{ lib, config, ... }:
let
  opts = config.pkgs.shell;

  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua {};

  mainMod = "SUPER";
  bind = key: action: args: { inherit key action args; };
  mkArrow = mod: action: args:
    lib.map
      (item: bind "${mod} + ${item.fst}" action [item.snd])
      (lib.zipLists ["H" "J" "K" "L" "left" "down" "up" "right"] (args ++ args));

  mkNum = mod: action: args:
    lib.map
      (item: bind "${mod} + ${toString item.fst}" action [item.snd])
      (lib.zipLists ((lib.range 1 9) ++ [0]) args);

  directions = map (direction: { inherit direction; }) ["left" "down" "up" "right"];
in {
  options = let
    inherit (lib) mkOption types;
  in {
    pkgs.shell.keybind = mkOption {
      type = types.listOf (types.submodule {
        options = {
          key = mkOption {
            type = types.str;
            description = "Key combination, e.g. SUPER + Q.";
          };

          action = mkOption {
            type = types.str;
            description = "Dispatcher name under hl.dsp, e.g. window.close or exec_cmd.";
          };

          args = mkOption {
            type = types.listOf types.anything;
            default = [];
            description = "Arguments passed to the dispatcher constructor.";
          };

          flags = mkOption {
            type = types.attrsOf types.bool;
            default = {};
            description = "Bind flags, e.g. repeating or mouse.";
          };
        };
      });
      default = [];
      description = "Hyprland keybindings rendered as Lua by the shell module.";
    };
  };

  config = {
    home.wayland.windowManager.hyprland.settings = {
      bind = map (bind: {
        _args = [
          bind.key
          (mkLuaInline "hl.dsp.${bind.action}(${lib.concatMapStringsSep ", " toLua bind.args})")
          bind.flags
        ];
      }) opts.keybind;

      gesture = [
        { fingers = 3; direction = "horizontal"; action = "workspace"; }
      ];
    };

    pkgs.shell.keybind = lib.flatten [
      # Close: Super + Q
      (bind "${mainMod} + Q" "window.close" [])

      # Focus: Super + (HJKL / Arrow)
      (mkArrow mainMod "focus" directions)

      # Move: Super + Ctrl + (HJKL / Arrow)
      (mkArrow "${mainMod} + CTRL" "window.swap" directions)

      # Zoom: Super + Z
      (bind "${mainMod} + Z" "window.fullscreen" [{ mode = "maximized"; }])

      # Float: Super + F
      (bind "${mainMod} + F" "window.float" [{ action = "toggle"; }])

      # Workspace: Super + Num / Super + (Shift +) Tab / Super + Scroll
      (mkNum mainMod "focus" (map (workspace: { inherit workspace; }) (lib.range 1 10)))
      (bind "${mainMod} + tab" "focus" [{ workspace = "m+1"; }])
      (bind "${mainMod} + SHIFT + tab" "focus" [{ workspace = "m-1"; }])
      (bind "${mainMod} + mouse_down" "focus" [{ workspace = "e+1"; }])
      (bind "${mainMod} + mouse_up" "focus" [{ workspace = "e-1"; }])

      # Workspace: Super + Shift + Num
      (mkNum "${mainMod} + SHIFT" "window.move"
        (map (workspace: { inherit workspace; follow = false; }) (lib.range 1 10)))

      # Launcher: Alt + Space
      (bind "ALT + Space" "exec_cmd" ["pkill anyrun || anyrun"])

      # Group: Super + (Shift +) G / Super + ][
      (bind "${mainMod} + G" "group.toggle" [])
      (bind "${mainMod} + SHIFT + G" "window.move" [{ out_of_group = true; }])
      (bind "${mainMod} + bracketleft" "group.prev" [])
      (bind "${mainMod} + bracketright" "group.next" [])

      # Lock, screenshot, recording and color picker.
      (bind "${mainMod} + CTRL + Q" "exec_cmd" ["loginctl lock-session"])
      (bind "${mainMod} + SHIFT + S" "exec_cmd" ["~/.config/hypr/scripts/screenshot.sh"])
      (bind "${mainMod} + SHIFT + R" "exec_cmd" ["~/.config/hypr/scripts/screenrecord.sh"])
      (bind "${mainMod} + SHIFT + P" "exec_cmd" [
        ''wl-copy -p $(hyprpicker -a) && notify-send "Color Picked"''
      ])

      # DPMS: Super + BrightnessUp
      (bind "${mainMod} + XF86MonBrightnessUp" "dpms" [{ action = "toggle"; }])

      # Resize: Super + Shift + (HJKL / Arrow)
      (map (binding: binding // { flags.repeating = true; })
        (mkArrow "${mainMod} + SHIFT" "window.resize" [
          { x = -10; y = 0; relative = true; }
          { x = 0; y = 10; relative = true; }
          { x = 0; y = -10; relative = true; }
          { x = 10; y = 0; relative = true; }
        ]))

      # Move/resize: Super + LMB/RMB
      { key = "${mainMod} + mouse:272"; action = "window.drag"; flags.mouse = true; }
      { key = "${mainMod} + mouse:273"; action = "window.resize"; flags.mouse = true; }
    ];
  };
}
