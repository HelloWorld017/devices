{ lib, pkgs, config, ... }:
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) attrsOf bool str submodule;
  in {
    pkgs.server.podman = {
      enable = mkOption {
        type = bool;
        default = true;
      };

      services = mkOption {
        type = attrsOf (submodule ({ name, ... }: {
          options = {
            enable = mkOption {
              type = bool;
            };

            path = mkOption {
              type = str;
              description = "path of the directory containing podman-compose.yml";
              default = "/srv/${config.constants.device}-${name}";
            };
          };
        }));
        default = {};
        description = "systemd services for podman";
      };
    };
  };

  config = let
    opts = config.pkgs.server.podman;
  in lib.mkIf opts.enable {
    systemd.services = lib.mapAttrs' (name: value: lib.nameValuePair "service-${name}" {
      enable = value.enable;
      after = [ "network-online.target" "podman.service" ];
      wants = [ "network-online.target" "podman.service" ];
      wantedBy = [ "multi-user.target" ];
      description = "Podman container service: ${name}";
      path = with pkgs; [podman podman-compose];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        WorkingDirectory = value.path;
        ExecStartPre = ''${pkgs.coreutils}/bin/sleep 1'';
        ExecStart = ''/bin/sh -c "podman compose up -d"'';
        ExecStop = ''/bin/sh -c "podman compose down"'';
      };
    }) opts.services;

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
  };
}
