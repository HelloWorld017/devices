{ ... }:
{
  config = {
    pkgs.server = {
      # Service
      podman.services.opencloud.enable = true;

      # Ingress
      ingress.rules."cloud.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = 20623;

        httpConfig = ''
          map $http_origin $opencloud_cors_origin {
            default "";
            "~*^https?://(.*\.)?nenw\.dev$" $http_origin;
          }
        '';

        location."/remote.php".proxyPass = "http://127.0.0.1:20623";
        location."/remote.php".extraConfig = ''
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
