{ config, ... }:
let
  ports = config.pkgs.server.ports.ports;
in {
  config = {
    pkgs.server = {
      # Service
      ports.allocation.names = [ "images" ];
      containers.services.images.pods = {
        images = {
          image = "docker.io/anirdev/slink:v1.14.4";
          environment = {
            IMAGE_MAX_SIZE = "15M";
            ORIGIN = "https://images.1e-9.space";
            STORAGE_PROVIDER = "local";
            TZ = "Asia/Seoul";
            USER_APPROVAL_REQUIRED = true;
          };

          ports = [
            { from = { addr = "127.0.0.1"; port = ports.images; }; to = 3000; }
          ];

          volumes = [
            { from = "slink_data"; to = "/app/var/data"; uid = 1000; gid = 1000; }
            { from = "slink_images"; to = "/app/slink/images"; uid = 1000; gid = 1000; }
          ];
        };
      };

      # Ingress
      ingress.rules."images.nenw.dev" = {
        acmeHost = "nenw.dev";

        locations."/".extraConfig = ''
          return 404;
        '';

        locations."^~ /image/" = {
          proxyPass = "http://127.0.0.1:${toString ports.images}";
        };
      };

      ingress.rules."images.1e-9.space" = {
        acmeHost = "1e-9.space";
        tailscale = true;
        proxyPort = ports.images;
      };
    };
  };
}
