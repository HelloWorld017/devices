{ ... }:
{
  config = {
    home.services.swayosd.enable = true;

    pkgs.shell.keybind = let
      bind = key: action: args: { inherit key action args; };
      bindRepeat = key: action: args: (bind key action args) // { flag.repeating = true; };
    in [
      (bind "XF86AudioMute" "exec_cmd" ["swayosd-client --output-volume mute-toggle"])
      (bind "XF86AudioMicMute" "exec_cmd" ["swayosd-client --input-volume mute-toggle"])
      (bindRepeat "XF86AudioRaiseVolume" "exec_cmd" ["swayosd-client --output-volume raise"])
      (bindRepeat "XF86AudioLowerVolume" "exec_cmd" ["swayosd-client --output-volume lower"])
      (bindRepeat "XF86MonBrightnessUp" "exec_cmd" ["swayosd-client --brightness raise"])
      (bindRepeat "XF86MonBrightnessDown" "exec_cmd" ["swayosd-client --brightness lower"])
    ];
  };
}
