{ self, config, lib, pkgs, ... }: let
  opts = config.pkgs.server.containers;
  podNetworkName = serviceName: serviceNetworkName:
    "${serviceName}_${serviceNetworkName}";
in {
  imports = [ ./options.nix ];
  config = let
    inherit (lib) concatStrings concatStringsSep elem escapeShellArg flatten isDerivation listToAttrs
      mapAttrs mapAttrs' mapAttrsToList mkDefault mkIf mkMerge nameValuePair optional unique;

    names = {
      target = serviceName: "containers-${serviceName}";
      network = serviceName: serviceNetworkName: "containers-${serviceName}-network-${serviceNetworkName}";
      passwords = serviceName: podName: "containers-${serviceName}-${podName}-passwords";
      pod = serviceName: podName: "containers-${serviceName}-${podName}";
    };

    buildNetworkServices = serviceName: service: let
      networks = unique (flatten (mapAttrsToList
        (podName: pod: pod.networks.effectiveNetworks)
        service.pods
      ));
    in
      listToAttrs (map (serviceNetworkName:
        (nameValuePair (names.network serviceName serviceNetworkName))
        (let
          networkId = (podNetworkName serviceName serviceNetworkName);
        in {
          description = "Create podman network ${serviceNetworkName} for ${serviceName}";
          wantedBy = [ "${names.target serviceName}.target" ];
          partOf = [ "${names.target serviceName}.target" ];
          after = [ "network-online.target" "podman.service" ];
          wants = [ "network-online.target" "podman.service" ];
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
            podman network create --ignore ${lib.escapeShellArg networkId}
          '';

          preStop = ''
            podman network rm --ignore ${lib.escapeShellArg networkId}
          '';
        })
      ) networks);

    buildPasswordServices = serviceName: service:
      mapAttrs' (podName: pod:
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

    buildContainerServices = serviceName: service:
      mapAttrs' (podName: pod:
        (nameValuePair (names.pod serviceName podName))
        (let
          dependencies = flatten [
            (optional pod.passwords.enable "${names.passwords serviceName podName}.service")
            (map
              (serviceNetworkName: "${names.network serviceName serviceNetworkName}.service")
              pod.networks.effectiveNetworks
            )
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

          serviceConfig = mkMerge [
            {
              Restart = mkDefault "always";
              RestartSec = mkDefault "5s";
              RestartMaxDelaySec = mkDefault "30s";
            }
            (mkIf (service.hostUser != "root") (let
              capabilities = unique (flatten [
                "CAP_NET_BIND_SERVICE"
                (mapAttrsToList
                    (capName: cap: optional (cap != null && cap.allowHost && cap.verdict) "CAP_${capName}")
                    pod.capabilities
                )
              ]);

              devices = flatten (map (device: let
                  permissions = concatStrings (unique (flatten [
                    (optional (elem "read" device.allowHost) "r")
                    (optional (elem "write" device.allowHost) "w")
                    (optional (elem "make" device.allowHost) "m")
                  ]));
                in optional (permissions != "") "${device.from} ${permissions}"
              ) pod.devices);
            in {
              DeviceAllow = devices;
              AmbientCapabilities = capabilities;
              CapabilityBoundingSet = capabilities;
            }))
          ];
        })
      ) service.pods;

    buildContainers = serviceName: service:
      mapAttrs' (podName: pod:
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

          networks = map (podNetworkName serviceName) pod.networks.effectiveNetworks;
          ports = map (mapping: "${mapping.from.value}:${toString mapping.to}") pod.ports;
          devices = map (mapping: "${mapping.from}:${mapping.to}") pod.devices;
          volumes = map (volume: volume.value) pod.volumes;

          # Permissions
          inherit (pod) privileged;
          capabilities = (mapAttrs
            (capName: cap: if cap == null then cap else cap.verdict)
            pod.capabilities
          );

          podman.user = service.hostUser;

          # Extra
          extraOptions = flatten [
            (optional (pod.networkAlias != null) "--network-alias=${pod.networkAlias}")
            (optional (pod.networks.kind != null) "--network=${pod.networks.kind}")
            (optional pod.noNewPrivileges "--security-opt=no-new-privileges")
          ];
        }
      ) service.pods;

    buildTargets = serviceName: service: {
      ${names.target serviceName} = {
        description = "Containers for ${serviceName}";
        after = [ "network-online.target" "podman.service" ];
        wants = [ "network-online.target" "podman.service" ];
        wantedBy = [ "multi-user.target" ];
      };
    };

  in mkIf opts.enable (mkMerge [
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

    (let
      build = fn: mapAttrsToList fn opts.services;
    in {
      virtualisation.oci-containers.containers = mkMerge (build buildContainers);
      systemd.targets = mkMerge (build buildTargets);
      systemd.services = mkMerge (flatten [
        (build buildContainerServices)
        (build buildPasswordServices)
        (build buildNetworkServices)
      ]);
    })
  ]);
}
