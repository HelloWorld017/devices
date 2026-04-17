{ self, lib, ... }: {
  config = let
    inherit (lib) mapAttrsToList;
    inherit (self.lib.river) blockset expr;
    uptimeProbes = {
      blog = "https://blog.nenw.dev";
      cloud = "https://cloud.nenw.dev";
    };
  in {
    pkgs.server = {
      # Service
      podman.services.observability.enable = true;

      # Ingress
      ingress.rules."dashboard.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = 20624;
      };

      # Observability
      observability.config = {
        "prometheus.exporter.blackbox" = blockset {
          uptime = {
            config = builtins.toJSON {
              modules = {
                http_2xx = {
                  prober = "http";
                  timeout = "5s";
                  http = { method = "GET"; preferred_ip_protocol = "ipv4"; };
                };
              };
            };

            target = blockset (
              mapAttrsToList
                (key: value: { name = key; address = value; module = "http_2xx"; })
                uptimeProbes
            );
          };
        };

        "prometheus.scrape" = blockset {
          uptime = {
            targets = expr "prometheus.exporter.blackbox.uptime.targets";
            forward_to = [ (expr "prometheus.remote_write.remote.receiver") ];
            job_name = "uptime";
          };
        };
      };

      # Firewall
      firewall.rules.observability = {
        from = [ "tailscale" ];
        allowedTCPPorts = [ 8428 9428 ];
      };
    };
  };
}
