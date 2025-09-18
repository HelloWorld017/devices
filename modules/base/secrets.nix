{ config, ... }:
{
	config = {
		age.identityPaths = let
			home = config.home.path;
		in [
			"${home}/.ssh/id_ed25519"
		];
	};
}
