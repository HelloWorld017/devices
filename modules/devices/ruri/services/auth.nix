{ config, ... }:
let
  ports = config.pkgs.server.ports.ports;
in {
  config = {
    pkgs.server = {
      # Service
      ports.allocation.names = [ "auth" ];
      containers.services.auth.pods.pocket-id = {
        image = "ghcr.io/pocket-id/pocket-id:v2.9.0";
        secrets = [
          { from = "ruri-auth-encryption-key"; to = "ENCRYPTION_KEY"; }
        ];

        environment = {
          APP_URL = "https://auth.nenw.dev";
          TRUST_PROXY = true;
          ANALYTICS_DISABLED = true;
          VERSION_CHECK_DISABLED = true;
        };

        ports = [
          { from = { addr = "127.0.0.1"; port = ports.auth; }; to = 1411; }
        ];

        volumes = [
          { from = "pocket_id_data"; to = "/app/data"; }
        ];
      };

      # Ingress
      ingress.rules."auth.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.auth;
      };
    };
  };
}
