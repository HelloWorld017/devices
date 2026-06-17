{ ... }:
{
  config = {
    pkgs.server = {
      # Ingress
      ingress.rules."cuttingedge.nenw.dev" = {
        acmeHost = "nenw.dev";
        locations."/" = {
          proxyPass = "http://nenw-akebi:8000";
        };
      };
    };
  };
}
