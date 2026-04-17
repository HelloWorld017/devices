{ self, config, ... }: {
  config = let
    inherit (self.lib.river) blockset expr;
    hostname = config.constants.host;
  in {
    pkgs.server = {
      # Service
      podman.services.e2email.enable = true;

      # Observability
      observability.config = {
        "prometheus.scrape" = blockset {
          e2email = {
            targets = [{
              __address__ = "127.0.0.1:10131";
              instance = hostname;
            }];
            forward_to = [ (expr "prometheus.remote_write.remote.receiver") ];
            job_name = "e2email";
          };
        };
      };
    };
  };
}
