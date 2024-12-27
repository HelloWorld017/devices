{
	imports = [
		./firewall.nix
		./services.nix
	];

	config = {
		virtualisation.docker.enabled = true;
	};
}
