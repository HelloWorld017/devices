{ ... }:
{
  config = {
    pkgs.server = {
      # Ingress
      ingress.rules."cuttingedge.nenw.dev" = {
        acmeHost = "nenw.dev";
        locations."/" = {
          proxyPass = "http://akebi-internal.zone.1e-9.space:8000";
        };
      };
    };
  };
}
