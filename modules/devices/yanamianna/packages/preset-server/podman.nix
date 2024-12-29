{ ... }:
{
	config = {
		virtualisation.podman = {
			enable = true;

			# Prune unused images periodically
			autoPrune = {
				enable = true;
				dates = "weekly";
				flags = ["--all"];
			};

			defaultNetwork.settings = {
				dns_enabled = true;
			};
		};
	};
}
