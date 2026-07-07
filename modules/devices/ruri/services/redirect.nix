{ lib, ... }:
{
  config = {
    pkgs.server.ingress.rules = let
      inherit (lib) concatMapAttrs listToAttrs removeAttrs map nameValuePair;
      rules = {
        root = {
          host = ["khinenw.tk" "nenw.moe"];
          domain = host: host;
          globalRedirect = "nenw.dev";
        };

        www = {
          host = ["khinenw.tk" "nenw.moe" "nenw.dev"];
          domain = host: "www.${host}";
          globalRedirect = "nenw.dev";
        };

        blog = {
          host = ["khinenw.tk" "nenw.moe"];
          domain = host: "blog.${host}";
          globalRedirect = "blog.nenw.dev";
        };

        git = {
          host = ["khinenw.tk"];
          domain = host: "git.${host}";
          locations."/" = {
            return = "301 https://github.com/HelloWorld017$request_uri";
          };
        };
      };
    in concatMapAttrs (name: value:
      listToAttrs (map
        (host: nameValuePair (value.domain host) (
          { acmeHost = host; }
          // (removeAttrs value ["host" "domain"])
        ))
        value.host
      )
    ) rules;
  };
}
