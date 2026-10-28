{ ... }:
{
  config = {
    home.services.hyprshell = {
      enable = true;
      settings = {
        windows = {
          scale = 5.5;
          items_per_row = 5;
          overview = null;
          switch = {
            modifier = "alt";
          };
        };
      };
    };

    pkgs.shell.execOnce = [ "hyprshell run" ];
  };
}
