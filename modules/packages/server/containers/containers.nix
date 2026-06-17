{ self, config, lib, pkgs, ... }: let
  opts = config.pkgs.server.services;
in {

  config = let
    inherit (lib) concatStringsSep escapeShellArg flatten isDerivation
      mapAttrs' mapAttrsToList mkIf mkMerge nameValuePair optional;

    buildNetworks = serviceName: service: {
      systemd.services = mapAttrs' (networkName: network:
        (nameValuePair "service-${serviceName}-network-${networkName}")
        {
          description = "Create podman network ${networkName} for ${serviceName}";
          wantedBy = [ "service-${serviceName}.target" ];
          partOf = [ "service-${serviceName}.target" ];
          path = [ config.virtualisation.podman.package ];

          environment = {
            HOME = mkIf (service.hostUser != "root") (config.users.users.${service.hostUser}.home);
            XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.${service.hostUser}.uid}";
          };

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = service.hostUser;
            Group = service.hostGroup;
          };

          script = ''
            podman network create --ignore ${lib.escapeShellArg network}
          '';

          preStop = ''
            podman network rm --ignore ${lib.escapeShellArg network}
          '';
        }
      ) service.networks;
    };

    buildPasswords = serviceName: service: {
      systemd.services = mapAttrs' (podName: pod:
        (nameValuePair "service-${serviceName}-password-${podName}")
        (mkIf pod.passwords.enable pod.passwords {
          description = "Derive environment passwords for ${podName} in ${serviceName}";
          wantedBy = [ "service-${serviceName}.target" ];
          partOf = [ "service-${serviceName}.target" ];

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

            dir="${escapeShellArg opts.passwords.directory}"
            out="${escapeShellArg pod.passwords.passwordFileName}"

            ${pkgs.coreutils}/bin/install -d -m 0711 -o root -g root "$dir"

            tmp="$(${pkgs.coreutils}/bin/mktemp "$out.XXXXXX")"
            trap 'rm -f "$tmp"' EXIT
            : > "$tmp"
            ${pkgs.coreutils}/bin/chown ${escapeShellArg service.hostUser}:${escapeShellArg service.hostGroup} "$tmp"
            ${pkgs.coreutils}/bin/chmod 0400 "$tmp"
            ${passwordLines}
            ${pkgs.coreutils}/bin/mv -f "$tmp" "$out"

            trap - EXIT
          '';
        })
      ) service.pods;
    };

    buildContainers = serviceName: service: {
      virtualisation.oci-containers.containers = mapAttrs' (podName: pod:
        (nameValuePair "${pod.containerName}")
        {
          # Images
          image =
            if isDerivation pod.image then "${pod.image.imageName}:${pod.image.imageTag}"
            else pod.image;

          imageStream =
            mkIf (isDerivation pod.image) (if pod.image ? "stream" then pod.image.stream else pod.image);

          pull = pod.pull;

          # Config
          inherit (pod) cmd entrypoint labels;

          # Lifecycle
          inherit (pod) dependsOn;
          autoStart = false;

          # Mappings
          inherit (pod) environment user;
          environmentFiles =
            pod.environmentFiles ++
            (optional pod.passwords.enable pod.passwords.fileName);

          networks = pod.networks.networks;
          ports = map (mapping: "${mapping.from}:${mapping.to}") pod.ports;
        }
      );
    };

  in mkIf opts.enable (mkMerge (flatten [
    (mapAttrsToList (serviceName: service: mkMerge [
      (buildNetworks serviceName service)
      (buildPasswords serviceName service)
      (buildContainers serviceName service)
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
  ]));
}
