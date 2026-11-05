{ lib, ... }:
{
  config = {
    services.openssh = {
      enable = true;
      ports = lib.mkDefault [ 22 ];
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "no";
      };
    };
  };
}
