{ config, lib, pkgs, ... }: {
  options = let
    inherit (lib) mkOption types;
    inherit (types) bool;
  in {
    pkgs.server.containers = {
      cli = {
        enable = mkOption {
          type = bool;
          default = true;
        };
      };
    };
  };

  config = let
    opts = config.pkgs.server.containers;
    inherit (lib) concatStringsSep escapeShellArg mapAttrsToList;

    targets = concatStringsSep "\n" (mapAttrsToList (serviceName: service: ''
      ${escapeShellArg serviceName})
        case "$pod" in
          ${concatStringsSep "\n" (mapAttrsToList (podName: pod: ''
            ${escapeShellArg podName})
              container=${escapeShellArg pod.containerName}
              unit=${escapeShellArg "containers-${serviceName}-${podName}.service"}
              ;;
          '') service.pods)}
          *) return 1 ;;
        esac
        host_user=${escapeShellArg service.hostUser}
        home=${escapeShellArg config.users.users.${service.hostUser}.home}
        ;;
    '') opts.services);

    listing = concatStringsSep "\n" (lib.flatten (mapAttrsToList
      (serviceName: service: mapAttrsToList (podName: pod:
        "printf '%s\\t%s\\t%s\\t%s\\n' ${lib.escapeShellArgs [ serviceName podName pod.containerName service.hostUser ]}"
      ) service.pods)
      opts.services));

    cli = pkgs.writeShellApplication {
      name = "server-container";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        usage() {
          cat <<'EOF'
        Usage:
          server-container list
          server-container shell SERVICE POD [-- COMMAND [ARG...]]
          server-container exec SERVICE POD -- COMMAND [ARG...]
          server-container logs SERVICE POD [-- PODMAN_LOGS_OPTIONS...]
          server-container inspect SERVICE POD [-- PODMAN_INSPECT_OPTIONS...]
          server-container status SERVICE POD [-- SYSTEMCTL_OPTIONS...]

        shell defaults to /bin/sh. exec automatically allocates a TTY on terminals.
        Commands run as the configured host user; sudo is used when necessary.
        EOF
        }

        die() {
          printf '%s\n' "$*" >&2
          exit 2
        }

        command=''${1:---help}
        case "$command" in
          -h|--help|help) usage; exit 0 ;;
          list)
            [[ $# -eq 1 ]] || die 'Usage: server-container list'
            printf 'SERVICE\tPOD\tCONTAINER\tHOST USER\n'
            ${listing}
            exit 0
            ;;
          shell|exec|logs|inspect|status) ;;
          *) die "Unknown command: $command (see server-container --help)" ;;
        esac

        [[ $# -ge 3 ]] || die "Usage: server-container $command SERVICE POD [-- ARGS...]"
        service=$2
        pod=$3
        shift 3
        if [[ ''${1:-} == -- ]]; then shift; fi

        container=""
        unit=""
        host_user=""
        home=""
        resolve_target() {
          case "$service" in
            ${targets}
            *) return 1 ;;
          esac
        }
        resolve_target || die "Unknown container: $service/$pod (see server-container list)"

        if [[ $command == status ]]; then
          exec ${config.systemd.package}/bin/systemctl status "$unit" "$@"
        fi

        if [[ $command == shell && $# -eq 0 ]]; then set -- /bin/sh; fi
        if [[ $command == exec && $# -eq 0 ]]; then die 'exec requires a command'; fi

        host_uid=$(id -u "$host_user")
        podman=( ${pkgs.coreutils}/bin/env -u CONTAINER_HOST -u CONTAINER_CONNECTION -u XDG_RUNTIME_DIR "HOME=$home" )
        if [[ $host_uid != 0 ]]; then
          podman+=( "XDG_RUNTIME_DIR=/run/user/$host_uid" )
        fi
        podman+=( ${config.virtualisation.podman.package}/bin/podman --remote=false )

        if [[ $(id -u) == "$host_uid" ]]; then
          runner=()
        elif [[ $(id -u) == 0 ]]; then
          runner=( ${pkgs.util-linux}/bin/runuser -u "$host_user" -- )
        else
          runner=( /run/wrappers/bin/sudo -H -u "$host_user" -- )
        fi

        case "$command" in
          shell|exec)
            flags=( -i )
            if [[ -t 0 && -t 1 ]]; then flags+=( -t ); fi
            exec "''${runner[@]}" "''${podman[@]}" exec "''${flags[@]}" "$container" "$@"
            ;;
          logs|inspect)
            exec "''${runner[@]}" "''${podman[@]}" "$command" "$@" "$container"
            ;;
        esac
      '';
    };
  in lib.mkIf opts.cli.enable {
    environment.systemPackages = [ cli ];
  };
}
