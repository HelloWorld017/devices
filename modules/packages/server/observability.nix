{ self, lib, config, pkgs, ... }:
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) attrs bool str;
  in {
    pkgs.server.observability = {
      enable = mkOption {
        type = bool;
        default = true;
      };

      remote = mkOption {
        type = str;
        default = "nenw-ajisai";
      };

      logs = mkOption {
        type = bool;
        default = true;
      };

      smartctl = mkOption {
        type = bool;
        default = true;
      };

      podman = mkOption {
        type = bool;
        default = true;
      };

      config = mkOption {
        type = attrs;
        default = {};
      };
    };
  };

  config = let
    inherit (self.lib.river) blockset block expr render;
    opts = config.pkgs.server.observability;
  in lib.mkIf opts.enable {
    pkgs.server.observability.config = lib.mkMerge [
      {
        "prometheus.remote_write" = blockset {
          remote = {
            endpoint = block {
              url = "http://${opts.remote}:8428/prometheus/api/v1/write";
            };
          };
        };

        "prometheus.exporter.unix" = blockset {
          node = {};
        };

        "prometheus.scrape" = blockset {
          node = {
            targets = expr "prometheus.exporter.unix.node.targets";
            forward_to = [ (expr "prometheus.remote_write.remote.receiver") ];
            job_name = "node";
          };

          podman = lib.mkIf opts.podman {
            targets = [
              {
                __address__ = "127.0.0.1:9882";
                instance = expr ''env("HOSTNAME")'';
              }
            ];
            forward_to = [ (expr "prometheus.remote_write.remote.receiver") ];
            job_name = "podman";
          };

          smartctl = lib.mkIf opts.smartctl {
            targets = [
              {
                __address__ = "127.0.0.1:9633";
                instance = expr ''env("HOSTNAME")'';
              }
            ];
            forward_to = [ (expr "prometheus.remote_write.remote.receiver") ];
            job_name = "smartctl";
          };
        };
      }
      (lib.mkIf opts.logs {
        "loki.write" = blockset {
          remote = {
            endpoint = block {
              url = "http://${opts.remote}:9428/insert/loki/api/v1/push";
            };
          };
        };

        "loki.relabel" = blockset {
          journal = {
            forward_to = [];

            rule = blockset [
              { source_labels = ["__journal__hostname"]; target_label = "host"; }
              { source_labels = ["__journal__systemd_unit"]; target_label = "unit"; }
              { source_labels = ["__journal_priority_keyword"]; target_label = "level"; }
            ];
          };
        };

        "loki.source.journal" = blockset {
          systemd = {
            forward_to = [ (expr "loki.write.remote.receiver") ];
            relabel_rules = expr "loki.relabel.journal.rules";
            labels = { source = "journald"; };
            format_as_json = true;
          };
        };
      })
    ];

    services.alloy.enable = true;
    services.alloy.configPath = pkgs.writeText "alloy.conf" (render opts.config);
    users.users.alloy.extraGroups = [ "systemd-journal" ];
  };
}

