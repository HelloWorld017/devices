{
	imports = [
		./acme.nix
		./firewall.nix
		./ingress.nix
		./podman.nix
		./services/auth.nix
		./services/cuttingedge.nix
		./services/blog.nix
		./services/mailserver.nix
		./services/openssh.nix
		./services/tailscale.nix
	];
}
