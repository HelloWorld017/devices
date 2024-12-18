{ inputs, pkgs, ... }:
{
	config = {
		home-manager.sharedModules = [
			inputs.anyrun.homeManagerModules.default
		];

		home.programs.anyrun = {
			enable = true;
			config = {
				plugins =
					let anyrunPkgs = inputs.anyrun.packages.${pkgs.system};
					in [
						anyrunPkgs.applications
					];
			};
		};
	};
}
