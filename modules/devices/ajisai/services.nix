{ repo, ... }:
{
  imports = [
    repo.server
    # ./services/e2email.nix
    ./services/observability.nix
    ./services/openssh.nix
    ./services/tailscale.nix
    ./services/wireray.nix
  ];

  config = {
    pkgs.server.acme.domainNames = [ "khinenw.tk" "nenw.moe" "nenw.dev" "nabi.moe" ];
    pkgs.server.ingress.zones = [ "cloudflare" "tailscale" ];
    pkgs.server.firewall.cloudflare.enable = true;
    pkgs.server.firewall.zones = {
      uplink = { interfaces = [ "ens3" ]; };
      podman = { interfaces = [ "podman*" ]; };
      tailscale = { interfaces = [ "tailscale*" ]; };
    };
  };
}
