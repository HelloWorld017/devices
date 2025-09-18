kind:
{ pkgs, inputs, ... }:
{
	imports = let
		modulesPath = if kind == "darwin" then "darwinModules" else "nixosModules";
		modules = [
			inputs.agenix.${modulesPath}.default
			inputs.home-manager.${modulesPath}.home-manager

			# This module could be used on darwin,
			# but the darwinModules field does not exist.
			inputs.agenix-template.nixosModules.default
		];
	in modules ++ [
		./brew.nix
		./env.nix
		./home.nix
		./nix.nix
		./secrets.nix
	];
}
