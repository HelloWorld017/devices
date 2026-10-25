{ config, lib, ... }: let
  inherit (lib) concatMap listToAttrs map nameValuePair;

  ports = config.pkgs.server.ports.ports;

  pagesHost = "pages.nenw.dev";
  pagesRoutes = [
    "bits"
    "irodori"
    "qrescan"
    "tone-marble"
  ];
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
      ports.allocation.names = [ "home" ];
      containers.services.home.pods.home = {
        image = "ghcr.io/helloworld017/nenwchan4:1.1.0";
        pull = "missing";

        ports = [
          { from = { addr = "127.0.0.1"; port = ports.home; }; to = 8080; }
        ];

        volumes = [
          { from = "data"; to = "/data"; }
        ];
      };

      ingress.rules."nenw.dev" = {
        acmeHost = "nenw.dev";
        locations = pagesLocation // {
          "/" = {
            proxyPass = "http://127.0.0.1:${toString ports.home}";
          };

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
