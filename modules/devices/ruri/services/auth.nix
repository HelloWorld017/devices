{ self, config, ... }:
let
  ports = config.pkgs.server.ports.ports;
in {
  config = {
    age.secrets."ruri-auth-encryption-key" = {
      file = self.lib.secret "ruri-auth-encryption-key.age";
    };

    pkgs.server = {
      # Service
      ports.allocation.names = [ "auth" ];
      containers.services.auth.pods.pocket-id = {
        image = "ghcr.io/pocket-id/pocket-id:v2.9.0";
        secrets = [
          { from = "ruri-auth-encryption-key"; to = "/app/encryption-key"; }
        ];

        environment = {
          APP_URL = "https://auth.nenw.dev";
          ENCRYPTION_KEY_FILE = "/app/encryption-key";
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
