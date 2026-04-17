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

      ingress.rules."cuttingedge2.nenw.dev" = {
        acmeHost = "nenw.dev";
        locations."/" = {
          proxyPass = "http://nenw-akebi:8001";
        };
      };
    };
  };
}
