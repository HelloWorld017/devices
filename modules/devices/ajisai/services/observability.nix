{ self, lib, config, pkgs, ... }: {
  config = let
    inherit (lib) mapAttrsToList toJSON;
    inherit (self.lib.river) blockset expr;

    ports = config.pkgs.server.ports.ports.observability;

    uptimeProbes = {
      blog = "https://blog.nenw.dev";
      cloud = "https://cloud.nenw.dev";
    };

    grafanaDatasource = pkgs.writeText "datasource.yml" (toJSON {
      apiVersion = 1;
      datasources = [
        {
          name = "VictoriaMetrics";
          type = "prometheus";
          access = "proxy";
          url = "http://victoriametrics:${ports.victoriametrics}";
          isDefault = true;
          jsonData = {
            prometheusType = "Prometheus";
            prometheusVersion = "2.24.0";
          };
        }
        {
          name = "VictoriaLogs";
          type = "victoriametrics-logs-datasource";
          access = "proxy";
          url = "http://victorialogs:${ports.victorialogs}";
          jsonData = {
            maxLines = 1000;
          };
        }
      ];
    });
  in {
    age.secrets."ajisai-grafana-password" = {
      file = self.lib.secret "ajisai-grafana-password.age";
    };

    pkgs.server = {
      # Ports
      ports = {
        allocation.names.observability = ["grafana"];
        ports.observability = {
          victoriametrics = 8428;
          victorialogs = 9428;
        };
      };

      # Service
      containers.services.observability.pods = {
        victoriametrics = {
          image = "docker.io/victoriametrics/victoria-metrics:v1.140.0";
          cmd = [
            "-storageDataPath=/storage"
            "-retentionPeriod=90d"
          ];

          volumes = [{ from = "victoriametrics"; to = "/storage"; }];
          ports = [{ from = ports.victoriametrics; to = 8428; }];
        };

        victorialogs = {
          image = "docker.io/victoriametrics/victoria-logs:v1.50.0";
          cmd = [
            "-storageDataPath=/storage"
            "-retentionPeriod=21d"
          ];

          volumes = [{ from = "victorialogs"; to = "/storage"; }];
          ports = [{ from = ports.victorialogs; to = 9428; }];
        };

        grafana = {
          image = "docker.io/grafana/grafana-oss:13.0.1";
          environment = {
            GF_SECURITY_ADMIN_USER = "nenw";
            GF_INSTALL_PLUGINS = "victoriametrics-logs-datasource";
            GF_SERVER_DOMAIN = "dashboard.nenw.dev";
            GF_SERVER_ROOT_URL = "https://dashboard.nenw.dev";
          };

          environmentFiles = [
            config.age.secrets.ajisai-grafana-password.path
          ];

          volumes = [
            { from = "grafana"; to = "/var/lib/grafana"; }
            { from = grafanaDatasource; to = "/etc/grafana/provisioning/datasources/datasource.yml"; readOnly = true; }
          ];

          ports = [
            { from = { addr = "127.0.0.1"; port = ports.grafana; }; to = 3000; }
          ];
        };
      };

      # Ingress
      ingress.rules."dashboard.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.grafana;
        tailscale = true;
      };

      # Observability
      observability.config = {
        "prometheus.exporter.blackbox" = blockset {
          uptime = {
            config = toJSON {
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
        allowedTCPPorts = [
          ports.victorialogs
          ports.victoriametrics
        ];
      };
    };
  };
}
