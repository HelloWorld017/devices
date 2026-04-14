{ ... }:
{
  config = {
    pkgs.server = {
      # Service
      podman.services.wireray.enable = true;

      # Ingress
      ingress.rules."test.nabi.moe" = {
        acmeHost = "nabi.moe";
        locations."/" = {
          proxyPass = "http://127.0.0.1:20619";
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
