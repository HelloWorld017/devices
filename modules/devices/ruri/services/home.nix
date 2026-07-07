{ config, lib, ... }: let
  inherit (lib) concatMap listToAttrs map nameValuePair;

  ports = config.pkgs.server.ports.ports;

  pagesHost = "pages.nenw.dev";
  pagesRoutes = [ "bits" "irodori" "tone-marble" ];
  pagesProxy = {
    proxyPass = "https://${pagesHost}";
    recommendedProxySettings = false;
    extraConfig = ''
      proxy_set_header Host ${pagesHost};
      proxy_ssl_name ${pagesHost};
      proxy_redirect https://${pagesHost}/ https://$host/;
      proxy_redirect https://${pagesHost} https://$host;
    '';
  };

  pagesLocation = listToAttrs (map
    (name: nameValuePair name pagesProxy)
    (concatMap (route: [ "= /${route}" "/${route}/" ]) pagesRoutes)
  );
in {
  config = {
    pkgs.server = {
      ingress.rules."nenw.dev" = {
        acmeHost = "nenw.dev";
        locations = pagesLocation // {
          "/" = pagesProxy;

          "= /.well-known/openid-configuration" = {
            proxyPass = "http://127.0.0.1:${toString ports.auth}";
          };

          "= /.well-known/webfinger" = {
            proxyPass = "http://127.0.0.1:${toString ports.misskey}";
          };
        };
      };
    };
  };
}
