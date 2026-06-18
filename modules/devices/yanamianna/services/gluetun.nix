{ self, config, ... }:
let
  ports = config.pkgs.server.ports.ports;
in {
  imports = [ (self.lib.private "yanamianna-gluetun.nix") ];
  config = {
    pkgs.server = {
      # Firewall
      firewall.rules.gluetun = {
        from = [ "local" "tailscale" ];
        allowedTCPPorts = [ ports.gluetun ];
      };
    };
  };
}
