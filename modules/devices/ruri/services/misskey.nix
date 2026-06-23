{ config, pkgs, ... }:
let
  ports = config.pkgs.server.ports.ports;
  misskey = pkgs.misskey.overrideAttrs (finalAttrs: previousAttrs: {
    version = "2026.6.0-beta.1-e52b40a";
    src = pkgs.fetchFromGitHub {
      owner = "HelloWorld017";
      repo = "misskey";
      rev = "288955e2a53c42d46bbb5d27818cacb367699f48";
      hash = "sha256-0CmJIQxeh3xCWnDRlhwabljy6Yt+vh2pRMp+1lJqSSk=";
      fetchSubmodules = true;
    };

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pkgs.pnpm_11;
      fetcherVersion = 4;
      hash = "sha256-Q3vV7ZI3sxyKLZAmI9/1i24NjQe0P3Il5i/jB5u/HEg=";
    };
  });

  misskeySettings = {
    url = "https://social.nenw.dev/";
    accountHost = "nenw.dev";
    port = 3000;
    db = {
      host = "database";
      port = 5432;
      db = "misskey";
      user = "misskey";
    };
    dbReplications = false;
    redis = {
      host = "redis";
      port = 6379;
    };
    fulltextSearch.provider = "sqlLike";
    id = "aidx";
  };

  misskeySettingsYamlFile =
    (pkgs.formats.yaml { }).generate "misskey-default.yml" misskeySettings;

  misskeySettingsJsonFile =
    (pkgs.formats.json { }).generate "misskey-default.json" misskeySettings;

  misskeyImage = pkgs.dockerTools.streamLayeredImage {
    name = "misskey";
    tag = misskey.version;
    contents = [
      misskey
      pkgs.busybox
      pkgs.dockerTools.usrBinEnv
      pkgs.dockerTools.binSh
      pkgs.dockerTools.caCertificates
      pkgs.dockerTools.fakeNss
    ];
    extraCommands = ''
      mkdir -p run/misskey var/lib/misskey tmp
      chmod 1777 tmp
    '';
    config = {
      Cmd = [ "${misskey}/bin/misskey" "migrateandstart" ];
      Env = [
        "MISSKEY_CONFIG_YML=/run/misskey/default.yml"
        "NODE_ENV=production"
        "HOME=/var/lib/misskey"
      ];
      WorkingDir = "${misskey}/data";
    };
  };
in {
  config = {
    pkgs.server = {
      # Service
      ports.allocation.names = [ "misskey" ];
      containers.services.misskey.pods = {
        web = {
          image = misskeyImage;
          pull = "never";
          dependsOn = [
            { pod = "database"; }
            { pod = "redis"; }
          ];

          passwords.environment = {
            DATABASE_PASSWORD = "database-password";
          };

          ports = [
            { from = { addr = "127.0.0.1"; port = ports.misskey; }; to = 3000; }
          ];

          volumes = [
            { from = "files"; to = "/var/lib/misskey"; }
            { from = misskeySettingsYamlFile; to = "/run/misskey/default.yml"; readOnly = true; }
            { from = misskeySettingsJsonFile; to = "/run/misskey/default.json"; readOnly = true; }
          ];
        };

        database = {
          image = "docker.io/postgres:18.4-alpine";
          environment = {
            POSTGRES_DB = "misskey";
            POSTGRES_USER = "misskey";
          };

          passwords.environment = {
            POSTGRES_PASSWORD = "database-password";
          };

          volumes = [
            { from = "postgres"; to = "/var/lib/postgresql"; mode = "0755"; }
          ];
        };

        redis = {
          image = "docker.io/valkey/valkey:9.1.0-alpine";
          volumes = [
            { from = "redis"; to = "/data"; mode = "1777"; }
          ];
        };
      };

      # Ingress
      ingress.rules."social.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.misskey;
        extraConfig = ''
          client_max_body_size 262m;
        '';
        locations."/".proxyWebsockets = true;
      };
    };
  };
}
