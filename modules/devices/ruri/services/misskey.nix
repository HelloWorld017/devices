{ config, lib, pkgs, ... }:
let
  ports = config.pkgs.server.ports.ports;
  misskey = pkgs.misskey.overrideAttrs (finalAttrs: previousAttrs: {
    version = "2026.6.0-beta.1-e52b40a";
    src = pkgs.fetchFromGitHub {
      owner = "HelloWorld017";
      repo = "misskey";
      rev = "e52b40a8b5d97e1dbad290a7045d75613325211f";
      hash = lib.fakeHash;
      fetchSubmodules = true;
    };

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pkgs.pnpm_11;
      fetcherVersion = 4;
      hash = lib.fakeHash;
    };
  });

  misskeySettings = {
    url = "https://misskey.nenw.dev/";
    host = "nenw.dev";
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

  misskeySettingsFile =
    (pkgs.formats.yaml { }).generate "misskey-default.yml" misskeySettings;

  misskeyImage = pkgs.dockerTools.streamLayeredImage {
    name = "misskey";
    tag = "develop";
    contents = [ misskey ];
    extraCommands = ''
      mkdir -p run/misskey var/lib/misskey tmp
      chmod 1777 tmp
    '';
    config = {
      Cmd = [ "${misskey}/bin/misskey" "migrateandstart" ];
      Env = [
        "MISSKEY_CONFIG_YML=/run/misskey/default.yml"
        "NODE_ENV=production"
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
            { pod = "db"; }
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
            { from = misskeySettingsFile; to = "/run/misskey/default.yml"; readOnly = true; }
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
            { from = "postgres"; to = "/var/lib/postgresql/data"; }
          ];
        };

        redis = {
          image = "docker.io/valkey/valkey:9.1.0-alpine";
          volumes = [
            { from = "redis"; to = "/data"; }
          ];
        };
      };

      # Ingress
      ingress.rules."misskey.nenw.dev" = {
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
