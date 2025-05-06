{ pkgs, inputs, ... }:
{
	imports = [
		inputs.wsl.nixosModules.default
	];

	config = {
		wsl.enable = true;

		home.packages = with pkgs; [
			(callPackage ./win32yank.nix {})
		];
	};
}
