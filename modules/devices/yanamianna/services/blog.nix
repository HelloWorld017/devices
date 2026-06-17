{ self, config, ... }:
let
  ports = config.pkgs.server.ports.ports;
  secrets = config.age.secrets;
in {
  config = {
    age.secrets."yanamianna-blog-database-password" = {
      file = self.lib.secret "yanamianna-blog-database-password.age";
    };

    age.secrets."yanamianna-blog-kaede-password" = {
      file = self.lib.secret "yanamianna-blog-kaede-password.age";
    };

    age.secrets."yanamianna-blog-kaede-database-password" = {
      file = self.lib.secret "yanamianna-blog-kaede-database-password.age";
    };

    pkgs.server = {
      # Service
      ports.allocation.names = [ "ghost" "kaede" ];
      containers.blog.pods = {
        ghost = {
          image = "docker.io/ghost:5.101-alpine";
          environment = {
            database__client = "mysql";
            database__connection__host = "db";
            database__connection__user = "root";
            database__connection__database = "ghost";
            url = "https://blog.nenw.dev";
          };

          environmentFiles = [ secrets.yanamianna-blog-database-password.path ];
          ports = [
            { from = { addr = "127.0.0.1"; port = ports.ghost; }; to = 2368; }
          ];

          volumes = [
            { from = "ghost_content"; to = "/var/lib/ghost/content"; }
          ];
        };

        db = {
          image = "docker.io/mysql:8.4";
          environmentFiles = [ secrets.yanamianna-blog-database-password.path ];
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

          environmentFiles = [
            secrets.yanamianna-blog-kaede-password.path
            secrets.yanamianna-blog-kaede-database-password.path
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

          environmentFiles = [ secrets.yanamianna-blog-kaede-database-password.path ];
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
