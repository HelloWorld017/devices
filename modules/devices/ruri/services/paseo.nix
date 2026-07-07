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

  paseoImageConfig = {
    "x86_64-linux" = {
      arch = "amd64";
      os = "linux";
      imageDigest = "sha256:656e046de970bc1056e828ce6dfd14a2cd23240977f949e2f2e04f21884d5fe0";
      sha256 = "sha256-phMlI/mW3/J9u1bqXT905McKyRG1542ksZ2TijOuGSc=";
    };

    "aarch64-linux" = {
      arch = "arm64";
      os = "linux";
      imageDigest = "sha256:b80c895b9f9de67b22af9b38b1dd343589f1705085bbb8966933259a3de81f6d";
      sha256 = "sha256-kp1cJJs6zS5PiRvcLBbWcVltFMM2FR4tPG7XpoN2T9o=";
    };
  };

  paseoBase = pkgs.dockerTools.pullImage (paseoImageConfig.${system} // {
    imageName = "ghcr.io/getpaseo/paseo";
    finalImageName = "ghcr.io/getpaseo/paseo";
    finalImageTag = "0.1.103";
  });

  paseo = pkgs.dockerTools.streamLayeredImage {
    name = "paseo-opencode";
    tag = "0.1.103";
    fromImage = paseoBase;
    contents = [ devTools ];
  };
in
{
  config = {
    pkgs.server = {
      ports.allocation.names.paseo = [ "paseo" "relay" ];
      containers.services.paseo.pods = {
        daemon = {
          image = paseo;
          pull = "never";

          environment = {
            PASEO_WEB_UI_ENABLED = "true";
            PASEO_LISTEN = "0.0.0.0:6767";
            PASEO_HOSTNAMES = "paseo.1e-9.space";
            PASEO_RELAY_ENDPOINT = "paseo-relay.1e-9.space:443";
            PASEO_RELAY_PUBLIC_ENDPOINT = "paseo-relay.1e-9.space:443";
            PASEO_RELAY_USE_TLS = "true";
          };

          ports = [
            {
              from = { addr = "127.0.0.1"; port = ports.paseo; };
              to = 6767;
            }
          ];

          volumes = [
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
          proxyPass = "https://127.0.0.1:${toString ports.relay}";

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
          proxyPass = "https://127.0.0.1:${toString ports.paseo}";

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
