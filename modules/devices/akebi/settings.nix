{ config, ... }:
{
  constants.device = "akebi";

  users.users.${config.constants.user} = {
    group = "nenw";
    extraGroups = [ "users" "libvirtd" ];
  };

  wsl.defaultUser = config.constants.user;

  virtualisation.podman = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };

    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  virtualisation.libvirtd.enable = true;

  pkgs.wsl.nvidia.enable = true;

  system.stateVersion = "24.11";
}
