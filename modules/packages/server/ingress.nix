{ pkgs, lib, config, ... }:
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) attrs bool listOf str;
  in {
    pkgs.server.ingress = {
      enable = mkOption {
        type = bool;
        default = true;
      };

      rules = mkOption {
        type = attrs;
        default = {};
        description = "virtual host rules for ingress";
      };

      zones = mkOption {
        type = listOf str;
        default = [ "all" ];
      };

      fence = {
        url = mkOption {
          type = str;
          default = "https://fence.1e-9.space";
        };
      };
    };
  };

  config = let
    opts = config.pkgs.server.ingress;
    selfSignedCert = (pkgs.runCommand
      "self-signed-cert"
      { nativeBuildInputs = [ pkgs.openssl ]; }
      ''
        mkdir -p $out
        openssl req -x509 -nodes \
          -newkey rsa:4096 \
          -keyout $out/privkey.pem \
          -out $out/fullchain.pem \
          -days 36500 \
          -subj "/CN=localhost" \
          -addext "subjectAltName = DNS:localhost,IP:127.0.0.1"

        chmod 644 $out/fullchain.pem
        chmod 600 $out/privkey.pem
      ''
    );

    fenceExtraConfig = ''
      auth_request /_fence;
      auth_request_set $tinyauth_redirect $upstream_http_x_tinyauth_location;

      auth_request_set $tinyauth_remote_user $upstream_http_remote_user;
      auth_request_set $tinyauth_remote_email $upstream_http_remote_email;
      auth_request_set $tinyauth_remote_name $upstream_http_remote_name;
      auth_request_set $tinyauth_remote_groups $upstream_http_remote_groups;
      auth_request_set $tinyauth_remote_sub $upstream_http_remote_sub;

      error_page 401 403 =302 $tinyauth_redirect;

      proxy_set_header Remote-User $tinyauth_remote_user;
      proxy_set_header Remote-Email $tinyauth_remote_email;
      proxy_set_header Remote-Name $tinyauth_remote_name;
      proxy_set_header Remote-Groups $tinyauth_remote_groups;
      proxy_set_header Remote-Sub $tinyauth_remote_sub;
    '';
  in lib.mkIf opts.enable {
    # Service
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      appendHttpConfig = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value:
          if (value ? httpConfig && value.httpConfig != "") then
            ''
              # Rules for ${name}
              ${value.httpConfig}
            ''
          else 
            ""
        ) opts.rules
      );

      virtualHosts = {
        "localhost" = {
          default = true;
          forceSSL = true;
          sslCertificate = "${selfSignedCert}/fullchain.pem";
          sslCertificateKey = "${selfSignedCert}/privkey.pem";
          locations."/".extraConfig = ''
            return 404;
          '';
        };
      } // (
        lib.mapAttrs (name: value: lib.mkMerge [
          { http2 = true; forceSSL = true; }
          (lib.mkIf (value ? "acmeHost") { useACMEHost = value.acmeHost; })
          (lib.mkIf (!(value ? "acmeHost")) { enableACME = true; })
          (lib.mkIf (value ? "proxyPort") {
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString value.proxyPort}/";
            };
          })
          (lib.mkIf (value ? "fence" && value.fence) {
            locations."/" = {
              extraConfig = fenceExtraConfig;
            };

            locations."/_fence" = {
              proxyPass = "${opts.fence.url}/api/auth/nginx";
              extraConfig = ''
                internal;

                proxy_pass_request_body off;
                proxy_set_header Content-Length "";
                proxy_set_header X-Forwarded-Uri $request_uri;
                proxy_set_header X-Original-Uri $request_uri;
              '';
            };
          })
          (removeAttrs value ["acmeHost" "fence" "httpConfig" "proxyPort" "tailscale"])
        ]) opts.rules
      );

      tailscaleAuth = let
        tailscaleEnabledRules = lib.flatten (
          lib.mapAttrsToList
            (name: rule: lib.optional (rule ? "tailscale" && rule.tailscale) name)
            opts.rules
        );
      in {
        enable = (lib.length tailscaleEnabledRules) > 0;
        virtualHosts = tailscaleEnabledRules;
      };
    };

    # Firewall
    pkgs.server.firewall.rules.ingress = {
      from = opts.zones;
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
