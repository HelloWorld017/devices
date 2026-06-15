{ ... }:
{
  config = {
    pkgs.server = {
      # Service
      podman.services.gluetun.enable = true;

      # Firewall
      firewall.rules.gluetun = {
        from = [ "local" "tailscale" ];
        allowedTCPPorts = [ 30021 ];
      };
    };
  };
}
