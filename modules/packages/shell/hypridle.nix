{ pkgs, ... }:
{
  config = {
    home.services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock --quiet";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = ''hyprctl dispatch "hl.dsp.dpms({ action = 'on' })"'';
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = 150;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10%";
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          {
            timeout = 180;
            on-timeout = ''hyprctl dispatch "hl.dsp.dpms({ action = 'off' })"'';
            on-resume = ''hyprctl dispatch "hl.dsp.dpms({ action = 'on' })"'';
          }
          {
            timeout = 210;
            on-timeout = "loginctl lock-session";
          }
        ];
      };
    };
  };
}
