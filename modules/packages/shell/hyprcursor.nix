{ inputs, system, ... }:
{
  config = {
    pkgs.shell.env.HYPRCURSOR_THEME = "rose-pine-hyprcursor";

    home.packages = [
      inputs.rose-pine-hyprcursor.packages.${system}.default
    ];
  };
}
