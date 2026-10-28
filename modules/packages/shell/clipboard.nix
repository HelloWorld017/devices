{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      wl-clip-persist
    ];

    pkgs.shell.execOnce = [ "wl-clip-persist --clipboard regular" ];
  };
}
