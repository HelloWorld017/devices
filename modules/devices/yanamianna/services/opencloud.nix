{ config, ... }:
let
  ports = config.pkgs.server.ports.ports;
in {
  config = {
    pkgs.server = {
      # Service
      ports.allocation.names = [ "opencloud" ];
      containers.services.opencloud.pods = let
        cspFile = builtins.toFile "opencloud-csp-auth.yaml" ''
          directives:
            connect-src:
              - "https://auth.nenw.dev"
        '';
      in {
        opencloud = {
          image = "docker.io/opencloudeu/opencloud-rolling:9.0.0";
          volumes = [
            { from = "opencloud-data"; to = "/var/lib/opencloud"; uid = 1000; gid = 1000; }
            { from = "opencloud-config"; to = "/etc/opencloud"; uid = 1000; gid = 1000; }
            { from = "${cspFile}"; to = "/etc/opencloud/csp-auth.yaml"; readOnly = true; }
          ];

          environment = {
            OC_URL = "https://cloud.nenw.dev";
            OC_INSECURE = true;
            PROXY_HTTP_ADDR = "0.0.0.0:9200";
            PROXY_TLS = false;

            # Auth Integration
            GRAPH_ASSIGN_DEFAULT_USER_ROLE = false;
            OC_EXCLUDE_RUN_SERVICES = "idp";
            OC_OIDC_CLIENT_ID = "87b995ca-5e93-4310-ba38-ee909ef5dccb";
            OC_OIDC_ISSUER = "https://auth.nenw.dev";
            PROXY_CSP_CONFIG_FILE_LOCATION = "/etc/opencloud/csp-auth.yaml";
            PROXY_OIDC_REWRITE_WELLKNOWN = true;
            PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
            PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM = "opencloud_role";
            PROXY_USER_OIDC_CLAIM = "email";
            PROXY_USER_CS3_CLAIM = "mail";
          };

          ports = [
            { from = { addr = "127.0.0.1"; port = ports.opencloud; }; to = 9200; }
          ];
        };
      };

      # Ingress
      ingress.rules."cloud.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.opencloud;

        httpConfig = ''
          map $http_origin $opencloud_cors_origin {
            default "";
            "~*^https?://(.*\.)?nenw\.dev$" $http_origin;
          }
        '';

        locations."/remote.php".proxyPass = "http://127.0.0.1:${toString ports.opencloud}";
        locations."/remote.php".extraConfig = ''
          # Find Actions
          set $cors_action "";

          if ($request_method = OPTIONS) {
            set $cors_action "OPTIONS";
          }

          if ($opencloud_cors_origin) {
            set $cors_action "''${cors_action}_ALLOWED";
          }

          # On Preflight
          if ($cors_action = "OPTIONS_ALLOWED") {
            add_header Access-Control-Allow-Origin $opencloud_cors_origin always;
            add_header Access-Control-Allow-Methods "GET, PUT, POST, DELETE, HEAD, OPTIONS, PROPFIND, MKCOL" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, Depth, Destination, If, If-Match, If-None-Match, If-Unmodified-Since, Overwrite, Range, x-amz-content-sha256, x-amz-date, x-amz-security-token, x-amz-user-agent" always;
            add_header Access-Control-Expose-Headers "ETag, Content-Length, Last-Modified, DAV, x-amz-request-id, x-amz-id-2, x-amz-version-id" always;
            add_header Access-Control-Allow-Credentials "true" always;
            add_header Access-Control-Max-Age "86400" always;
            return 204;
          }

          # On CORS Request
          if ($opencloud_cors_origin) {
            add_header Access-Control-Allow-Origin $opencloud_cors_origin always;
            add_header Access-Control-Expose-Headers "ETag, Content-Length, Last-Modified, DAV, x-amz-request-id, x-amz-id-2, x-amz-version-id" always;
            add_header Access-Control-Allow-Credentials "true" always;
          }
        '';
      };
    };
  };
}
