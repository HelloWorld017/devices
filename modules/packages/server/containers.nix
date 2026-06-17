{ self, config, lib, pkgs, ... }: let
  opts = config.pkgs.server.containers;
  configRoot = config;
  podContainerName = serviceName: podName:
    opts.services.${serviceName}.pods.${podName}.containerName;
in {
  options = let
    inherit (lib) all attrNames concatStringsSep filter flatten hasAttr hasPrefix isAttrs isList isString
      length mkOption mkOptionType optional types;

    inherit (types) addCheck attrsOf coercedTo bool enum externalPath ints listOf nullOr oneOf
      package path port str submodule;

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

    device = coercedTo str
      (path: { from = path; to = path; })
      (mapping externalPath externalPath);

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

    networks = serviceName: let
      shorthand = mkOptionType {
        name = "network reference";
        check = value:
          (isList value && all isString value)
          || (hasOnly "host" value && value.host == true)
          || (hasOnly "container" value && (isString value.container))
          || (hasOnly "pod" value && (isString value.pod));
      };
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
        (submodule {
          options = {
            kind = mkOption { type = nullOr str; default = null; };
            networks = mkOption { type = listOf str; default = []; };
          };
        });

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
          (hasOnly "hostPath" value && (path.check value.hostPath))
          || (hasOnly "service" value && (isString value.service))
          || (hasOnly "volume" value && (isString value.volume));
      };
    in
      coercedTo
        (oneOf [ path str shorthand ])
        (reference:
          if isAttrs reference then
            if reference ? "hostPath" then (toString reference.hostPath)
            else if reference ? "volume" then reference.volume
            else (servicePath reference.service)
          else if (path.check reference) then (toString reference)
          else (servicePath reference)
        )
        str;

    volume = serviceName: submodule ({ config, ... }: {
      options = {
        from = mkOption { type = volumeReference serviceName; };
        to = mkOption { type = externalPath; };
        readOnly = mkOption { type = bool; default = false; };
        chown = mkOption {
          type = bool;
          default = !config.readOnly && (hasPrefix "${opts.services.${serviceName}.path}/" config.from);
        };
        value = mkOption { type = str; readOnly = true; };
      };

      config.value = concatStringsSep ":" (filter (x: x != "") [
        config.from
        config.to
        (concatStringsSep "," (flatten [
          (optional config.readonly "ro")
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
          type = attrsOf str;
          default = {};
        };

        environmentFiles = mkOption {
          type = listOf path;
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
          default = if (length config.networks.networks > 0) then name else null;
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
          type = attrsOf (nullOr bool);
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

  config = let
    inherit (lib) concatStringsSep escapeShellArg flatten isDerivation listToAttrs mapAttrs'
      mapAttrsToList mkDefault mkIf mkMerge nameValuePair optional unique;

    names = {
      target = serviceName: "containers-${serviceName}";
      network = serviceName: networkName: "containers-${serviceName}-network-${networkName}";
      passwords = serviceName: podName: "containers-${serviceName}-${podName}-passwords";
      pod = serviceName: podName: "containers-${serviceName}-${podName}";
    };

    buildNetworks = serviceName: service: let
      networks = unique (flatten (mapAttrsToList (podName: pod: pod.networks.networks) service.pods));
    in {
      systemd.services = listToAttrs (map (networkName:
        (nameValuePair (names.network serviceName networkName))
        {
          description = "Create podman network ${networkName} for ${serviceName}";
          wantedBy = [ "${names.target serviceName}.target" ];
          partOf = [ "${names.target serviceName}.target" ];
          after = [ "network-online.target" ];
          path = [ config.virtualisation.podman.package ];

          environment = mkIf (service.hostUser != "root") {
            HOME = (config.users.users.${service.hostUser}.home);
            XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.${service.hostUser}.uid}";
          };

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = service.hostUser;
            Group = service.hostGroup;
          };

          script = ''
            podman network create --ignore ${lib.escapeShellArg networkName}
          '';

          preStop = ''
            podman network rm --ignore ${lib.escapeShellArg networkName}
          '';
        }
      ) networks);
    };

    buildPasswords = serviceName: service: {
      systemd.services = mapAttrs' (podName: pod:
        (nameValuePair (names.passwords serviceName podName))
        (mkIf pod.passwords.enable {
          description = "Derive environment passwords for ${podName} in ${serviceName}";
          wantedBy = [ "${names.target serviceName}.target" ];
          partOf = [ "${names.target serviceName}.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = false;
          };

          script = let
            salt = "wwdrTjUURvYH49d0WccI8dozOzpXbM3PslnqOzUpDm";
            passwordLines =
              concatStringsSep "\n" (
                mapAttrsToList
                  (envName: context: ''
                    printf '%s=' ${escapeShellArg envName} >> "$tmp"

                    ${pkgs.openssl}/bin/openssl pkeyutl \
                      -kdf HKDF \
                      -kdflen 32 \
                      -pkeyopt digest:SHA256 \
                      -pkeyopt salt:${escapeShellArg salt} \
                      -pkeyopt info:${escapeShellArg "${serviceName}_${context}"} \
                      -pkeyopt_passin key:stdin \
                      < ${escapeShellArg pod.passwords.seedFileName} \
                      | ${pkgs.coreutils}/bin/base64 -w0 >> "$tmp"

                    printf '\n' >> "$tmp"
                  '')
                  pod.passwords.environment
              );
          in ''
            set -euo pipefail
            umask 077

            dir=${escapeShellArg opts.passwords.directory}
            out=${escapeShellArg pod.passwords.fileName}

            ${pkgs.coreutils}/bin/install -d -m 0711 -o root -g root "$dir"

            tmp="$(${pkgs.coreutils}/bin/mktemp "$out.XXXXXX")"
            trap 'rm -f "$tmp"' EXIT
            : > "$tmp"
            ${pkgs.coreutils}/bin/chown ${escapeShellArg "${service.hostUser}:${service.hostGroup}"} "$tmp"
            ${pkgs.coreutils}/bin/chmod 0400 "$tmp"
            ${passwordLines}
            ${pkgs.coreutils}/bin/mv -f "$tmp" "$out"

            trap - EXIT
          '';
        })
      ) service.pods;
    };

    buildContainers = serviceName: service: {
      systemd.services = mapAttrs' (podName: pod:
        (nameValuePair (names.pod serviceName podName))
        (let
          dependencies = flatten [
            (optional pod.passwords.enable "${names.passwords serviceName podName}.service")
            (map (networkName: "${names.network serviceName networkName}.service") pod.networks.networks)
          ];
        in {
          description = "Create container for ${podName} in ${serviceName}";
          wantedBy = [ "${names.target serviceName}.target" ];
          partOf = [ "${names.target serviceName}.target" ];
          after = dependencies;
          requires = dependencies;
          unitConfig = {
            StartLimitIntervalSec = mkDefault 300;
            StartLimitBurst = mkDefault 5;
          };
          serviceConfig = {
            Restart = mkDefault "always";
            RestartSec = mkDefault "5s";
            RestartMaxDelaySec = mkDefault "30s";
          };
        })
      ) service.pods;

      virtualisation.oci-containers.containers = mapAttrs' (podName: pod:
        (nameValuePair "${pod.containerName}")
        {
          # Images
          image =
            if isDerivation pod.image then "${pod.image.imageName}:${pod.image.imageTag}"
            else pod.image;

          imageStream =
            mkIf (isDerivation pod.image) (if pod.image ? "stream" then pod.image.stream else pod.image);

          inherit (pod) pull;

          # Config
          inherit (pod) cmd entrypoint labels;

          # Lifecycle
          inherit (pod) dependsOn;
          autoStart = false;
          serviceName = (names.pod serviceName podName);

          # Mappings
          inherit (pod) environment user;
          environmentFiles =
            pod.environmentFiles ++
            (optional pod.passwords.enable pod.passwords.fileName);

          networks = pod.networks.networks;
          ports = map (mapping: "${mapping.from.value}:${mapping.to}") pod.ports;
          devices = map (mapping: "${mapping.from}:${mapping.to}") pod.devices;
          volumes = map (volume: volume.value) pod.volumes;

          # Permissions
          inherit (pod) privileged capabilities;
          podman.user = service.hostUser;

          # Extra
          extraOptions = flatten [
            (optional (pod.networkAlias != null) "--network-alias=${pod.networkAlias}")
            (optional (pod.networks.kind != null) "--network=${pod.networks.kind}")
            (optional pod.noNewPrivileges "--security-opt=no-new-privileges")
          ];
        }
      ) service.pods;
    };

    buildTargets = serviceName: {
      systemd.targets.${names.target serviceName} = {
        description = "Containers for ${serviceName}";
        wants = [ "network-online.target" "podman.service" ];
        wantedBy = [ "multi-user.target" ];
      };
    };

  in mkIf opts.enable (mkMerge (flatten [
    (mapAttrsToList (serviceName: service: mkMerge [
      (buildNetworks serviceName service)
      (buildPasswords serviceName service)
      (buildContainers serviceName service)
      (buildTargets serviceName)
    ]) opts.services)

    (mkIf opts.user.enable {
      users.users.${opts.user.name} = {
        uid = opts.user.uid;
        group = opts.user.name;
        home = opts.user.home;
        subUidRanges = [{ startUid = 100000; count = 65536; }];
        subGidRanges = [{ startGid = 100000; count = 65536; }];
        isSystemUser = true;
        linger = true;
        createHome = true;
      };

      users.groups.${opts.user.name} = {
        gid = opts.user.uid;
      };
    })

    {
      age.secrets.containers-passwords-seed = {
        file = self.lib.secret "containers-passwords-seed.age";
      };

      virtualisation.oci-containers.backend = "podman";
      virtualisation.podman = {
        enable = true;

        # Prune unused images periodically
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = ["--all"];
        };

        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };

      pkgs.server.firewall.zones = {
        podman = { interfaces = [ "podman*" ]; };
      };

      pkgs.server.firewall.rules.podman = {
        from = [ "podman" ];
        allowedUDPPorts = [ 53 ];
      };

      pkgs.server.firewall.rules.podman-forward = {
        from = [ "podman" ];
        to = [ "all" ];
        verdict = "accept";
      };
    }
  ]));
}
