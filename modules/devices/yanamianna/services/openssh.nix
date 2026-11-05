{ config, repo, ... }:
{
  imports = [ repo.openssh ];

  config = {
    pkgs.server = {
      ports = {
        ports.openssh = 22;
      };

      firewall.rules.ssh = {
        from = [ "tailscale" "local" ];
        allowedTCPPorts = [ config.pkgs.server.ports.ports.openssh ];
      };
    };
  };
}
