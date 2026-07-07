{ pkgs, config, inputs, system, ... }:

let
  ports = config.pkgs.server.ports.ports.paseo;

  devTools = pkgs.buildEnv {
    name = "paseo-dev-tools";
    paths = with pkgs; [
      bashInteractive
      clang_22
      cmake
      coreutils
      curl
      dig
      fd
      git
      gnumake
      jq
      nodejs
      inputs.llm-agents.packages.${system}.opencode
      openssh
      pkg-config
      pnpm
      python314
      ripgrep
      unzip
      uv
      zip
      zsh
    ];

    pathsToLink = [
      "/bin"
      "/etc"
      "/share"
    ];
  };
in
{
  config = {
    pkgs.server = {
      ports.allocation.names.paseo = [ "paseo" "relay" ];
      containers.services.paseo.pods = {
        daemon = {
          image = "ghcr.io/getpaseo/paseo:0.1.103";
          pull = "missing";

          environment = {
            PASEO_WEB_UI_ENABLED = "true";
            PASEO_LISTEN = "0.0.0.0:6767";
            PASEO_HOSTNAMES = "paseo.1e-9.space";
            PASEO_RELAY_ENDPOINT = "paseo-relay.1e-9.space:443";
            PASEO_RELAY_PUBLIC_ENDPOINT = "paseo-relay.1e-9.space:443";
            PASEO_RELAY_USE_TLS = "true";

            # "Magic"
            PATH = "${devTools}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
          };

          ports = [
            {
              from = { addr = "127.0.0.1"; port = ports.paseo; };
              to = 6767;
            }
          ];

          volumes = [
            { from = "/nix/store"; to = "/nix/store"; readOnly = true; }
            { from = "home"; to = "/home/paseo"; mode = "0750"; }
            { from = "workspace"; to = "/workspace"; mode = "0770"; }
          ];
        };

        relay = {
          image = "ghcr.io/zenghongtu/paseo-relay:latest";
          pull = "missing";

          environment = {
            RELAY_ADDR = ":8411";
            LOG_FORMAT = "json";
          };

          ports = [
            {
              from = { addr = "127.0.0.1"; port = ports.relay; };
              to = 8411;
            }
          ];
        };
      };

      ingress.rules."paseo-relay.1e-9.space" = {
        acmeHost = "1e-9.space";

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${toString ports.relay}";

          extraConfig = ''
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
          '';
        };
      };

      ingress.rules."paseo.1e-9.space" = {
        acmeHost = "1e-9.space";
        fence = true;

        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${toString ports.paseo}";

          extraConfig = ''
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
            client_max_body_size 100m;
          '';
        };
      };
    };
  };
}
