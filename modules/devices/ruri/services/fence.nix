{ config, ... }:
let
  ports = config.pkgs.server.ports.ports;
  authUrl = "https://auth.nenw.dev";
in {
  config = {
    pkgs.server = {
      # Service
      ports.allocation.names = [ "fence" ];
      containers.services.fence.pods.tinyauth = {
        image = "ghcr.io/steveiliop56/tinyauth:v5.0.7";

        environment = {
          TINYAUTH_APPURL = "https://fence.1e-9.space";
          TINYAUTH_SERVER_ADDRESS = "0.0.0.0";
          TINYAUTH_SERVER_PORT = 3000;
          TINYAUTH_DATABASE_PATH = "/data/tinyauth.db";
          TINYAUTH_RESOURCES_PATH = "/data/resources";
          TINYAUTH_AUTH_SECURECOOKIE = true;
          TINYAUTH_AUTH_TRUSTEDPROXIES = "127.0.0.1/32,::1/128";

          TINYAUTH_OAUTH_AUTOREDIRECT = "pocketid";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_NAME = "Pocket ID";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_AUTHURL = "${authUrl}/authorize";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_TOKENURL = "${authUrl}/api/oidc/token";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_USERINFOURL = "${authUrl}/api/oidc/userinfo";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_REDIRECTURL = "https://fence.1e-9.space/api/oauth/callback/pocketid";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_CLIENTID = "e1e5ce4f-334c-41a9-854b-bb6572acc53d";
          TINYAUTH_OAUTH_PROVIDERS_POCKETID_SCOPES = "openid email profile groups";

          TINYAUTH_ANALYTICS_ENABLED = false;
          TINYAUTH_UI_TITLE = "nenw* Auth Fence";
          TINYAUTH_LOG_LEVEL = "info";
        };

        secrets = [
          {
            from = "ruri-fence-pocket-id-client-secret";
            to = "TINYAUTH_OAUTH_PROVIDERS_POCKETID_CLIENTSECRET";
          }
        ];

        ports = [
          { from = { addr = "127.0.0.1"; port = ports.fence; }; to = 3000; }
        ];

        volumes = [
          { from = "data"; to = "/data"; }
        ];
      };

      # Ingress
      ingress.rules."fence.1e-9.space" = {
        acmeHost = "1e-9.space";
        proxyPort = ports.fence;
      };
    };
  };
}
