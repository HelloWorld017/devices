{ config, ... }:
let
  ports = config.pkgs.server.ports.ports.blog;
in {
  config = {
    pkgs.server = {
      # Service
      ports.allocation.names.blog = [ "ghost" "kaede" ];
      containers.services.blog.pods = {
        ghost = {
          image = "docker.io/ghost:6.73-alpine";
          dependsOn = [{ pod = "db"; }];
          environment = {
            database__client = "mysql";
            database__connection__host = "db";
            database__connection__user = "root";
            database__connection__database = "ghost";
            security__staffDeviceVerification = "false";
            url = "https://blog.nenw.dev";
          };

          secrets = [
            { from = "yanamianna-blog-database-password"; to = "database__connection__password"; }
          ];

          ports = [
            { from = { addr = "127.0.0.1"; port = ports.ghost; }; to = 2368; }
          ];

          volumes = [
            { from = "ghost_content"; to = "/var/lib/ghost/content"; uid = 1000; gid = 1000; }
          ];
        };

        db = {
          image = "docker.io/mysql:8.4";
          secrets = [
            { from = "yanamianna-blog-database-password"; to = "MYSQL_ROOT_PASSWORD"; }
          ];

          volumes = [
            { from = "ghost_database"; to = "/var/lib/mysql"; uid = 999; gid = 999; }
          ];
        };

        kaede = {
          image = "ghcr.io/helloworld017/kaede-api:2.1.0";
          dependsOn = [ { pod = "ghost"; } ];
          environment = {
            GHOST_URL = "https://blog.nenw.dev";
          };

          secrets = [ "yanamianna-blog-kaede-password" ];
          volumes = [ { from = "kaede_database"; to = "/data"; } ];
          ports = [
            { from = { addr = "127.0.0.1"; port = ports.kaede; }; to = 11005; }
          ];
        };
      };

      # Ingress
      ingress.rules."blog.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.ghost;
      };

      ingress.rules."kaede.nenw.dev" = {
        acmeHost = "nenw.dev";
        proxyPort = ports.kaede;
      };
    };
  };
}
