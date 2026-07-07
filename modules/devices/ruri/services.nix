{ repo, ... }:
{
  imports = [
    repo.server
    ./services/auth.nix
    ./services/fence.nix
    ./services/home.nix
    ./services/misskey.nix
    ./services/openssh.nix
    ./services/redirect.nix
    ./services/tailscale.nix
  ];

  config = {
    pkgs.server.acme.domainNames = [ "1e-9.space" "khinenw.tk" "nenw.moe" "nenw.dev" ];
    pkgs.server.ingress.zones = [ "cloudflare" "tailscale" ];
    pkgs.server.firewall.cloudflare.enable = true;
    pkgs.server.firewall.zones = {
      uplink = { interfaces = [ "enp0s6" ]; };
      podman = { interfaces = [ "podman*" ]; };
      tailscale = { interfaces = [ "tailscale*" ]; };
    };
  };
}
