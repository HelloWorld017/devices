{ repo, ... }:
{
  imports = [
    repo.server
    ./services/openssh.nix
    ./services/tailscale.nix
  ];

  config = {
    pkgs.server.acme.domainNames = [ "nenw.dev" ];
    pkgs.server.ingress.zones = [ "cloudflare" "tailscale" ];
    pkgs.server.firewall.cloudflare.enable = true;
    pkgs.server.firewall.zones = {
      uplink = { interfaces = [ "enp0s6" ]; };
      podman = { interfaces = [ "podman*" ]; };
      tailscale = { interfaces = [ "tailscale*" ]; };
    };
  };
}
