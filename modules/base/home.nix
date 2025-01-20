{ pkgs, lib, options, ... }:
let
	user = "nenw";
in with lib; {
	options = with types; {
		home = {
			file = mkOption {
				type = attrs;
				default = {};
				description = "Files to place directly in $HOME";
			};

			configFile = mkOption {
				type = attrs;
				default = {};
				description = "Config files to place in $HOME/.config";
			};

			defaultApplications = mkOption {
				type = attrs;
				default = {};
				description = "Default applications to open mime (currently not active)";
			};

			services = mkOption {
				type = attrs;
				default = {};
				description = "Home-manager provided user services";
			};

			packages = mkOption {
				type = listOf package;
				default = [];
				description = "Home-manager provided packages";
			};

			programs = mkOption {
				type = attrs;
				default = {};
				description = "Home-manager provided programs";
			};

			fonts = mkOption {
				type = attrs;
				default = {};
				description = "Home-manager provided fonts";
			};

			wayland = mkOption {
				type = attrs;
				default = {};
				description = "Home-manager provided wayland settings";
			};
		};
	};

	config = {
		programs.zsh.enable = true;
		users.users.${user} = {
			name = user;
			home = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
			shell = pkgs.zsh;
		};

		# Initialize Home
		home-manager = {
			useUserPackages = true;
			useGlobalPkgs = true;

			users.${user} = {
				home = {
					file = mkAliasDefinitions options.home.file;
					packages = mkAliasDefinitions options.home.packages;
					stateVersion = "22.05";
				};
				fonts = mkAliasDefinitions options.home.fonts;
				programs = mkAliasDefinitions options.home.programs;
				services = mkAliasDefinitions options.home.services;
				wayland = mkAliasDefinitions options.home.wayland;
				xdg = {
					mimeApps = {
						enable = false;
						defaultApplications = mkAliasDefinitions options.home.defaultApplications;
					};
					configFile = mkAliasDefinitions options.home.configFile;
				};
			};
		};
	};
}
