{ config, lib, ... }:
let
  ports = config.pkgs.server.ports.ports.mailserver;
  # TODO(nixpkgs/podman6): Revert this temporary direct-pasta + nftables workaround
  # when upgrading, after verifying source-IP preservation and low-port publishing.
  # It avoids rootlessport losing client IPs and rootless privileged-port bind failures.
  mailPorts = {
    smtp = 25;
    pop3 = 110;
    imap = 143;
    smtp-tls = 465;
    imaps = 993;
    pop3s = 995;
  };
  mappings = lib.mapAttrsToList (name: port: {
    from = port;
    to = ports.forward.${name};
  }) mailPorts;
  redirectRules = lib.concatMapStringsSep "\n" (mapping:
    "fib daddr type local tcp dport ${toString mapping.from} redirect to :${toString mapping.to}"
  ) mappings;
in {
  config = {
    assertions = [
      {
        assertion = lib.all (mapping: mapping.to >= 1024) mappings;
        message = "Mailserver forwarding ports must be unprivileged ports (>= 1024).";
      }
    ];

    networking.nftables.tables.mailserver-redirect = {
      family = "inet";
      content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;
          ${redirectRules}
        }

        chain output {
          type nat hook output priority dstnat; policy accept;
          ${redirectRules}
        }
      '';
    };

    pkgs.server = {
      # Service
      ports = {
        allocation.names = lib.mkMerge [
          { mailserver = [ "webmail" "jmap" ]; }
          { mailserver.forward = lib.attrNames mailPorts; }
        ];
        ports.mailserver = mailPorts;
      };

      containers.services.mailserver.pods = {
        mailserver = {
          image = "docker.io/stalwartlabs/stalwart:v1.0.0-alpine";
          # Direct pasta forwarding preserves external clients' source addresses.
          networks.kind = "pasta";
          # The image's non-root user needs the binary's file capability to bind low ports.
          noNewPrivileges = false;
          environment = {
            STALWART_PUBLIC_URL = "https://mail.nenw.dev";
          };

          ports = lib.mapAttrsToList (name: port:
            { from = ports.forward.${name}; to = port; }
          ) mailPorts ++ [
            { from = { addr = "127.0.0.1"; port = ports.jmap; }; to = 8080; }
          ];

          volumes = [
            { from = "mailserver-config"; to = "/etc/stalwart"; uid = 2000; gid = 2000; }
            { from = "mailserver-data"; to = "/var/lib/stalwart"; uid = 2000; gid = 2000; }
          ];
        };

        webmail = {
          image = "ghcr.io/bulwarkmail/webmail:1.18.0";
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
            OAUTH_CLIENT_ID = "56faf120-3f28-46c4-b65c-0322e3614400";
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

        locations."/".extraConfig = ''
            # Prevent duplicate upstream CORS headers
            proxy_hide_header Access-Control-Allow-Origin;
            proxy_hide_header Access-Control-Allow-Methods;
            proxy_hide_header Access-Control-Allow-Headers;
            proxy_hide_header Access-Control-Allow-Credentials;

            # Allow only Bulwark
            add_header Access-Control-Allow-Origin "https://webmail.1e-9.space" always;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-JMAP-Prefix, X-JMAP-Request-Id" always;
            add_header Access-Control-Allow-Credentials "true" always;
            add_header Vary "Origin" always;

            client_max_body_size 50m;
        '';
      };

      ingress.rules."webmail.1e-9.space" = {
        acmeHost = "1e-9.space";
        proxyPort = ports.webmail;
      };

      # Firewall
      firewall.extraInputRules = ''
        # Accept redirected mail traffic, but reject direct access to the high ports.
        ${lib.concatMapStringsSep "\n" (mapping:
          "ct status dnat tcp dport ${toString mapping.to} ct original proto-dst ${toString mapping.from} accept"
        ) mappings}
        tcp dport { ${lib.concatMapStringsSep ", " (mapping: toString mapping.to) mappings} } drop
      '';

      firewall.rules.mailserver = {
        from = [ "all" ];
        allowedTCPPorts = lib.attrValues mailPorts;
      };
    };
  };
}
