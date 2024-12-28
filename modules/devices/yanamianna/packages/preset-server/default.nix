{
	imports = [
		./firewall.nix
		./ingress.nix
		./services/openssh.nix
	];

	config = {
		virtualisation.podman.enable = true;
	};
}
