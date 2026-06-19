{ self, config, lib, ... }:
let
  enable = false;
  ports = config.pkgs.server.ports.ports;
in {
  imports = [ (self.lib.private "ajisai-wireray.nix") ];

  config = lib.mkIf enable {
    pkgs.server = {
      # Ingress
      ingress.rules."test.nabi.moe" = {
        acmeHost = "nabi.moe";
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString ports.wireray}";
          extraConfig = ''
            client_max_body_size 0;

            proxy_buffering off;
            proxy_request_buffering off;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
            keepalive_timeout 3600s;

            gzip off;
            access_log off;
          '';
        };
      };
    };
  };
}
