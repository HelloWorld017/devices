{ pkgs, ... }:
{
	config = {
		home.packages = with pkgs; [
			crystal-dock
		];
	};
}
