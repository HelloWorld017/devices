{ self, ... }: {
  config = let
    inherit (self.lib.river) blockset block expr;
  in {
    pkgs.server.observability.config = {
      "otelcol.receiver.otlp" = blockset {
        local_apps = {
          http = block { endpoint = "127.0.0.1:4318"; };
          output = block {
            metrics = [ (expr "otelcol.exporter.prometheus.otlp.input") ];
          };
        };
      };

      "otelcol.exporter.prometheus" = blockset {
        otlp = {
          forward_to = [ (expr "prometheus.remote_write.victoriametrics.receiver") ];
        };
      };
    };
  };
}
