{ config, lib, ... }:
let
  ports = config.pkgs.server.ports.ports.mailserver;
in {
  config = {
    pkgs.server = {
      # Service
      ports = {
        allocation.names.mailserver = [ "webmail" "jmap" ];
        ports.mailserver = {
          smtp = 25;
          pop3 = 110;
          imap = 143;
          smtp-starttls = 587;
          imaps = 993;
          pop3s = 995;
        };
      };

      containers.services.mailserver.pods = {
        mailserver = {
          image = "docker.io/stalwartlabs/stalwart:v0.16.26";
          environment = {
            STALWART_PUBLIC_URL = "https://mail.nenw.dev";
          };

          ports = [
            /* { from = ports.smtp; to = 25; }
            { from = ports.pop3; to = 110; }
            { from = ports.imap; to = 143; }
            { from = ports.smtp-starttls; to = 587; }
            { from = ports.imaps; to = 993; }
            { from = ports.pop3s; to = 995; } */
            { from = { addr = "127.0.0.1"; port = ports.jmap; }; to = 8080; }
          ];

          volumes = [
            { from = "mailserver-config"; to = "/etc/stalwart"; uid = 2000; gid = 2000; }
            { from = "mailserver-data"; to = "/var/lib/stalwart"; uid = 2000; gid = 2000; }
          ];
        };

        webmail = {
          image = "ghcr.io/bulwarkmail/webmail:1.15.0";
          dependsOn = [ { pod = "mailserver"; } ];
          ports = [
            { from = { addr = "127.0.0.1"; port = ports.webmail; }; to = 3000; }
          ];

          environment = {
            HOSTNAME = "0.0.0.0";
            PORT = "3000";
            APP_NAME = "nenw* mail";
            JMAP_SERVER_URL = "https://mail.nenw.dev";
            OAUTH_ENABLED = "true";
            OAUTH_ONLY = "true";
            OAUTH_CLIENT_ID = "d092461b-3f00-44d1-97ef-589d069607b3";
            OAUTH_ISSUER_URL = "https://auth.nenw.dev";
            BULWARK_TELEMETRY = "off";
          };

          volumes = [
            { from = "webmail-settings"; to = "/app/data/settings"; uid = 1001; gid = 1001; }
            { from = "webmail-admin"; to = "/app/data/admin"; uid = 1001; gid = 1001; }
            { from = "webmail-admin-state"; to = "/app/data/admin-state"; uid = 1001; gid = 1001; }
            { from = "webmail-telemetry"; to = "/app/data/telemetry"; uid = 1001; gid = 1001; }
          ];

          secrets = [
            { from = "yanamianna-mail-webmail-session-secret"; to = "SESSION_SECRET"; }
          ];
        };
      };

      # Ingress
      ingress.rules."mail.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.jmap;
      };

      ingress.rules."webmail.1e-9.space" = {
        acmeHost = "1e-9.space";
        proxyPort = ports.webmail;
      };

      # Firewall
      firewall.rules.mailserver = {
        from = [ "all" ];
        allowedTCPPorts = lib.attrValues {
          inherit (ports) smtp pop3 imap smtp-starttls imaps pop3s;
        };
      };
    };
  };
}
