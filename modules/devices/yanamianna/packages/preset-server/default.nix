{
	imports = [
		./acme.nix
		./firewall.nix
		./ingress.nix
		./podman.nix
		./services/auth.nix
		./services/cuttingedge.nix
		./services/blog.nix
		./services/gluetun.nix
		./services/images.nix
		./services/mailserver.nix
		./services/openssh.nix
		./services/tailscale.nix
	];
}
