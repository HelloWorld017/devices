{ self, config, ... }:
let
  ports = config.pkgs.server.ports.ports;
in {
  config = {
    imports = [ (self.lib.private "yanamianna-gluetun.nix") ];
    pkgs.server = {
      # Firewall
      firewall.rules.gluetun = {
        from = [ "local" "tailscale" ];
        allowedTCPPorts = [ ports.gluetun ];
      };
    };
  };
}
