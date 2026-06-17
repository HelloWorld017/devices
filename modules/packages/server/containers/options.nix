{ self, config, lib, ... }: let
  opts = config.pkgs.server.services;
  podContainerName = serviceName: podName: opts.services.${serviceName}.pods.${podName}.containerName;
in {
  options = let
    inherit (lib) attrNames concatStringsSep filter flatten isAttrs length mkOption optional types;
    inherit (types) attrsOf coercedTo bool enum ints listOf nullOr oneOf package path port str submodule;

    mapping = fromType: toType: submodule {
      options = {
        from = mkOption { type = fromType; };
        to = mkOption { type = toType; };
      };
    };

    address = submodule ({ config, ... }: {
      options = {
        addr = mkOption { type = nullOr str; };
        port = mkOption { type = nullOr port; };
        normalized = mkOption { type = str; readOnly = true; };
      };

      config.normalized = let
        hasAddr = config.addr != null;
        hasPort = config.port != null;
      in
        if hasAddr && hasPort then "${config.addr}:${toString config.port}"
        else if hasAddr then "${config.addr}:"
        else if hasPort then toString config.port
        else "";
    });

    passwords = serviceName: podName: let
      passwordSubmodule = submodule ({ config, ... }: {
        options = {
          enable = mkOption {
            type = bool;
            readOnly = true;
          };

          fileName = mkOption {
            type = str;
            readOnly = true;
          };

          seedFileName = mkOption {
            type = path;
            default = self.lib.secret "containers-passwords-seed";
          };

          environment = mkOption {
            type = attrsOf str;
            default = {};
          };
        };

        config = {
          enable = (length (attrNames config.environment)) > 0;
          fileName = "${opts.passwords.directory}/${podContainerName serviceName podName}.env";
        };
      });
    in oneOf [
      (coercedTo (attrsOf str) (environment: { inherit environment; }) passwordSubmodule)
      passwordSubmodule
    ];

    networks = serviceName:
      coercedTo
        (oneOf [
          (submodule {
            options.host = mkOption { type = enum [ true ]; };
          })
          (submodule {
            options.container = mkOption { type = str; };
          })
          (submodule {
            options.pod = mkOption { type = str; };
          })
          (listOf str)
        ])
        (reference:
          if reference ? "host" then { kind = "host"; }
          else if reference ? "container" then { kind = "container:${reference.container}"; }
          else if reference ? "pod" then { kind = "container:${podContainerName serviceName reference.pod}"; }
          else { kind = null; networks = reference; }
        )
        (submodule {
          options = {
            kind = mkOption { type = str; };
            networks = mkOption { type = listOf str; default = []; };
          };
        });

    containerReference = serviceName:
      coercedTo
        (oneOf [
          (submodule {
            options.container = mkOption { type = str; };
          })
          (submodule {
            options.pod = mkOption { type = str; };
          })
        ])
        (reference:
          if reference ? "container" then reference.container
          else podContainerName serviceName reference.pod
        )
        str;

      volumeReference = serviceName: let
        servicePath = name: "${opts.services.${serviceName}.path}/${name}";
        volumeReferenceSubmodule = submodule {
          options = {
            hostPath = mkOption { type = nullOr path; default = null; };
            service = mkOption { type = nullOr str; default = null; };
            volume = mkOption { type = nullOr str; default = null; };
          };
        };
      in coercedTo
        (oneOf [ path str volumeReferenceSubmodule ])
        (reference:
          if isAttrs reference then
            if reference.hostPath != null then reference.hostPath
            else if reference.service != null then (servicePath reference.service)
            else if reference.volume != null then reference.volume
            else null
          else if (path.check reference) then reference
          else (servicePath reference)
        )
        str;

      volume = serviceName:
        coercedTo
          (submodule ({ config, ... }: {
            options = {
              from = mkOption { type = volumeReference; };
              to = mkOption { type = path; };
              readonly = mkOption { type = bool; default = false; };
              chown = mkOption { type = bool; default = !config.readonly; };
            };
          }))
          (volume: concatStringsSep ":" (filter (x: x != "") [
            volume.from
            volume.to
            (concatStringsSep "," (flatten [
              (optional volume.readonly "ro")
              (optional volume.chown "u")
            ]))
          ]))
          str;

    container = serviceName: submodule ({ name, ... }: {
      options = {
        # Images
        image = mkOption {
          type = oneOf [ str package ];
        };

        pull = mkOption {
          type = enum [ "always" "missing" "never" "newer" ];
          default = "missing";
        };

        # Configs
        containerName = mkOption {
          type = str;
          default = "${serviceName}_${name}";
        };

        cmd = mkOption {
          type = listOf str;
          default = [];
        };

        entrypoint = mkOption {
          type = nullOr str;
          default = null;
        };

        labels = mkOption {
          type = attrsOf str;
          default = {};
        };

        # Lifecycle
        dependsOn = mkOption {
          type = listOf (containerReference serviceName);
        };

        # Mappings
        environment = mkOption {
          type = attrsOf str;
          default = {};
        };

        environmentFiles = mkOption {
          type = listOf str;
          default = [];
        };

        passwords = mkOption {
          type = (passwords serviceName name);
          default = {};
        };

        networks = mkOption {
          type = (networks serviceName);
          default = [];
        };

        user = mkOption {
          type = nullOr str;
          default = null;
        };

        ports = mkOption {
          type = listOf (mapping address port);
          default = [];
        };

        volumes = mkOption {
          type = listOf volume;
          default = [];
        };

        devices = mkOption {
          type = listOf (mapping path path);
          default = [];
        };

        # Permissions
        privileged = mkOption {
          type = bool;
          default = false;
        };

        capabilities = mkOption {
          type = attrsOf bool;
          default = {};
        };
      };
    });

    service = submodule ({ name, config, ... }: {
      options = {
        pods = mkOption {
          type = attrsOf (container name);
        };

        path = mkOption {
          type = path;
          default = "${opts.basePath}/${config.constants.device}-${name}";
        };

        hostUser = mkOption {
          type = str;
          default = opts.user.name;
        };

        hostGroup = mkOption {
          type = str;
          default = config.hostUser;
        };
      };
    });
  in {
    pkgs.server.containers = {
      enable = mkOption {
        type = bool;
        default = true;
      };

      basePath = mkOption {
        type = path;
        default = "/srv";
      };

      user = {
        enable = mkOption {
          type = bool;
          default = true;
        };

        uid = mkOption {
          type = nullOr ints.positive;
          default = 961;
        };

        name = mkOption {
          type = str;
          default = "containers-service";
        };

        home = mkOption {
          type = str;
          default = "/var/lib/containers-service";
        };
      };

      passwords = {
        directory = mkOption {
          type = path;
          default = "/run/containers-service/passwords";
        };
      };

      services = attrsOf service;
    };
  };
}
