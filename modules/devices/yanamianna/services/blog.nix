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
          image = "docker.io/ghost:5.101-alpine";
          environment = {
            database__client = "mysql";
            database__connection__host = "db";
            database__connection__user = "root";
            database__connection__database = "ghost";
            url = "https://blog.nenw.dev";
          };

          secrets = [
            { from = "yanamianna-blog-database-password"; to = "database__connection__password"; }
          ];

          ports = [
            { from = { addr = "127.0.0.1"; port = ports.ghost; }; to = 2368; }
          ];

          volumes = [
            { from = "ghost_content"; to = "/var/lib/ghost/content"; }
          ];
        };

        db = {
          image = "docker.io/mysql:8.4";
          secrets = [
            { from = "yanamianna-blog-database-password"; to = "MYSQL_ROOT_PASSWORD"; }
          ];

          volumes = [
            { from = "ghost_database"; to = "/var/lib/mysql"; }
          ];
        };

        kaede = {
          image = "docker.io/khinenw/kaede-api:1.0.2";
          dependsOn = [{ pod = "kaede-db"; }];
          environment = {
            GHOST_URL = "https://blog.nenw.dev";
            MONGODB_HOST = "kaede-db";
            MONGODB_USERNAME = "root";
          };

          secrets = [
            "yanamianna-blog-kaede-password"
            { from = "yanamianna-blog-kaede-database-password"; to = "MONGODB_PASSWORD"; }
          ];

          ports = [
            { from = { addr = "127.0.0.1"; port = ports.kaede; }; to = 11005; }
          ];
        };

        kaede-db = {
          image = "docker.io/mongo:5.0.30";
          environment = {
            MONGO_INITDB_ROOT_USERNAME = "root";
          };

          secrets = [
            { from = "yanamianna-blog-kaede-database-password"; to = "MONGODB_INITDB_ROOT_PASSWORD"; }
          ];

          volumes = [
            { from = "kaede_database"; to = "/data/db"; }
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
