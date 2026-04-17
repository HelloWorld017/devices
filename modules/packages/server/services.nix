{ pkgs, config, lib, ... }:
{
  options = let
    inherit (lib) mkOption types;
    inherit (types) bool;
  in {
    pkgs.server.services = {
      enable = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = let
    opts = config.pkgs.server.services;
  in lib.mkIf opts.enable {
    systemd.services.init-services = {
      description = "Initialize services repo";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [ git openssh ];

      script = ''
        if [ ! -d "$TARGET_DIR" ]; then
          export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"
          git clone "git@github.com:HelloWorld017/services.git" /srv
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        User = config.constants.user;
        Group = "users";

        ExecStartPre = [
          "+${pkgs.coreutils}/bin/mkdir -p /srv"
          "+${pkgs.coreutils}/bin/chown ${config.constants.user}:users /srv"
        ];
      };
    };
  };
}
