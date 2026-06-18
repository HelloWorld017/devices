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
          image = "docker.io/anirdev/slink:v1.10.6";
          environment = {
            IMAGE_MAX_SIZE = "15M";
            ORIGIN = "https://images.nenw.dev";
            STORAGE_PROVIDER = "local";
            TZ = "Asia/Seoul";
            USER_APPROVAL_REQUIRED = true;
          };

          ports = [
            { from = { addr = "127.0.0.1"; port = ports.images; }; to = 3000; }
          ];

          volumes = [
            { from = "slink_data"; to = "/app/var/data"; }
            { from = "slink_images"; to = "/app/slink/images"; }
          ];
        };
      };

      # Ingress
      ingress.rules."images.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.images;
      };
    };
  };
}
