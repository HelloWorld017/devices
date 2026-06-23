{ config, lib, ... }: let
  opts = config.pkgs.server.containers;
  configRoot = config;
  podContainerName = serviceName: podName:
    opts.services.${serviceName}.pods.${podName}.containerName;
in {
  options = let
    inherit (lib) all attrNames concatStringsSep filter flatten hasAttr isAttrs isList isString
      length mapAttrs mkOption mkOptionType optional optionals types;

    inherit (types) addCheck attrsOf coercedTo bool enum int ints listOf nullOr oneOf
      package path port str submodule;

    externalPath = if types ? "externalPath" then types.externalPath else path;

    hasOnly = name: value:
      isAttrs value && ((attrNames value) == [name]);

    mapping = fromType: toType: submodule {
      options = {
        from = mkOption { type = fromType; };
        to = mkOption { type = toType; };
      };
    };

    address = let
      addressSubmodule = submodule ({ config, ... }: {
        options = {
          port = mkOption { type = nullOr port; default = null; };
          addr = mkOption { type = nullOr str; default = null; };
          value = mkOption { type = str; readOnly = true; };
        };

        config.value =
          if config.addr != null && config.port != null then "${config.addr}:${toString config.port}"
          else if config.addr != null then "${config.addr}:"
          else if config.port != null then toString config.port
          else throw "an address should have addr or port";
      });
    in
      coercedTo port
        (port: { inherit port; })
        addressSubmodule;

    device = let
      deviceSubmodule = submodule {
        options = {
          from = mkOption { type = path; };
          to = mkOption { type = path; };
          allowHost = mkOption {
            type = listOf (enum ["read" "write" "make"]);
            default = ["read" "write" "make"];
          };
        };
      };
    in
      coercedTo str
        (path: { from = path; to = path; })
        deviceSubmodule;

    capabilities = let
      capabilitySubmodule = submodule ({ config, ... }: {
        options = {
          verdict = mkOption { type = bool; };
          allowHost = mkOption {
            type = bool;
            default = config.verdict;
          };
        };
      });

      capability = coercedTo bool
        (verdict: { inherit verdict; })
        capabilitySubmodule;
    in
      attrsOf (nullOr capability);

    environment = coercedTo (attrsOf (oneOf [ str int bool ]))
      (env: mapAttrs (name: value: toString value) env)
      (attrsOf str);

    passwords = serviceName: podName: let
      passwordSubmodule = submodule ({ config, ... }: {
        options = {
          enable = mkOption { type = bool; readOnly = true; };
          fileName = mkOption { type = str; readOnly = true; };
          seedFileName = mkOption {
            type = externalPath;
            default = configRoot.age.secrets.containers-passwords-seed.path;
          };
          environment = mkOption { type = attrsOf str; default = {}; };
        };

        config = {
          enable = (length (attrNames config.environment)) > 0;
          fileName = "${opts.passwords.directory}/${podContainerName serviceName podName}.env";
        };
      });
      reservedKeys = [ "seedFileName" "environment" ];
      shorthand =
        addCheck (attrsOf str)
          (attrs: all (name: !(hasAttr name attrs)) reservedKeys);
    in
      coercedTo
        shorthand
        (environment: { inherit environment; })
        passwordSubmodule;

    secret = let
      secretSubmodule = submodule ({ config, ... }: {
        options = {
          from = mkOption { type = str; };
          to = mkOption {
            type = nullOr (oneOf [ str path ]);
            default = null;
          };
          kind = mkOption {
            type = enum [ "environmentFile" "environment" "volume" ];
            readOnly = true;
          };
        };

        config.kind =
          if config.to == null then "environmentFile"
          else if path.check config.to then "volume"
          else "environment";
      });
    in
      coercedTo str
        (from: { inherit from; })
        secretSubmodule;

    networks = serviceName: let
      shorthand = mkOptionType {
        name = "network reference";
        check = value:
          (isList value && all isString value)
          || (hasOnly "host" value && value.host == true)
          || (hasOnly "container" value && (isString value.container))
          || (hasOnly "pod" value && (isString value.pod));
      };

      serviceNetwork = optional opts.services.${serviceName}.defaultNetwork "default";
    in
      coercedTo
        shorthand
        (reference:
          if isList reference then { kind = null; networks = reference; }
          else if reference ? "host" then { kind = "host"; }
          else if reference ? "container" then { kind = "container:${reference.container}"; }
          else if reference ? "pod" then { kind = "container:${podContainerName serviceName reference.pod}"; }
          else throw "networks field has unknown shape"
        )
        (submodule ({ config, ...}: {
          options = {
            kind = mkOption { type = nullOr str; default = null; };
            networks = mkOption { type = listOf str; default = []; };
            effectiveNetworks = mkOption {
              type = listOf str;
              readOnly = true;
            };
          };

          config.effectiveNetworks = optionals
            (config.kind == null)
            (if (length config.networks > 0) then config.networks else serviceNetwork);
        }));

    containerReference = serviceName: let
      shorthand = mkOptionType {
        name = "container reference";
        check = value:
          (hasOnly "container" value && (isString value.container))
          || (hasOnly "pod" value && (isString value.pod));
      };
    in
      coercedTo
        shorthand
        (reference:
          if reference ? "container" then reference.container
          else podContainerName serviceName reference.pod
        )
        str;

    volumeReference = serviceName: let
      servicePath = name: "${opts.services.${serviceName}.path}/${name}";
      shorthand = mkOptionType {
        name = "volume reference";
        check = value:
          (path.check value)
          || (isString value)
          || (hasOnly "hostPath" value && (path.check value.hostPath))
          || (hasOnly "servicePath" value && (isString value.servicePath))
          || (hasOnly "volume" value && (isString value.volume));
      };
      volumeReferenceSubmodule = submodule {
        options = {
          kind = mkOption { type = enum [ "hostPath" "servicePath" "volume" ]; };
          value = mkOption { type = str; };
        };
      };
    in
      coercedTo
        shorthand
        (reference: let
          coerced = if (path.check reference) then { hostPath = reference; }
            else { servicePath = reference; };
        in
          if coerced ? "hostPath" then
            { kind = "hostPath"; value = (toString coerced.hostPath); }
          else if coerced ? "volume" then
            { kind = "volume"; value = coerced.volume; }
          else
            { kind = "servicePath"; value = (servicePath coerced.servicePath); }
        )
        volumeReferenceSubmodule;

    fileMode = mkOptionType {
      name = "file mode";
      check = value:
        isString value
        && (builtins.match "[0-7][0-7][0-7][0-7]?" value) != null;
    };

    volume = serviceName: submodule ({ config, ... }: {
      options = {
        from = mkOption { type = volumeReference serviceName; };
        to = mkOption { type = externalPath; };
        readOnly = mkOption { type = bool; default = false; };
        mode = mkOption { type = fileMode; default = "0750"; };
        chown = mkOption {
          type = bool;
          default = !config.readOnly && (config.from.kind == "servicePath");
        };
        value = mkOption { type = str; readOnly = true; };
      };

      config.value = concatStringsSep ":" (filter (x: x != "") [
        config.from.value
        config.to
        (concatStringsSep "," (flatten [
          (optional config.readOnly "ro")
          (optional config.chown "U")
        ]))
      ]);
    });

    dockerImage =
      addCheck package (drv: drv ? imageName && drv ? imageTag);

    container = serviceName: submodule ({ name, config, ... }: {
      options = {
        # Images
        image = mkOption {
          type = oneOf [ str dockerImage ];
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
          default = [];
        };

        # Mappings
        environment = mkOption {
          type = environment;
          default = {};
        };

        environmentFiles = mkOption {
          type = listOf path;
          default = [];
        };

        secrets = mkOption {
          type = listOf secret;
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

        networkAlias = mkOption {
          type = nullOr str;
          default = if (length config.networks.effectiveNetworks > 0) then name else null;
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
          type = listOf (volume serviceName);
          default = [];
        };

        devices = mkOption {
          type = listOf device;
          default = [];
        };

        # Permissions
        noNewPrivileges = mkOption {
          type = bool;
          default = true;
        };

        privileged = mkOption {
          type = bool;
          default = false;
        };

        capabilities = mkOption {
          type = capabilities;
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
          type = externalPath;
          default = "${opts.basePath}/${configRoot.constants.device}-${name}";
        };

        defaultNetwork = mkOption {
          type = bool;
          default = true;
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
        type = externalPath;
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
          type = externalPath;
          default = "/var/lib/containers-service";
        };
      };

      passwords = {
        directory = mkOption {
          type = externalPath;
          default = "/run/containers-service/passwords";
        };
      };

      services = mkOption {
        type = attrsOf service;
        default = {};
      };
    };
  };
}
