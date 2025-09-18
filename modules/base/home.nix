{ pkgs, lib, config, options, ... }:
with lib; {
	options = with types; {
		home = {
			user = mkOption {
				type = str;
				default = "nenw";
				description = "User name";
			};

			path = mkOption {
				type = str;
				default = if pkgs.stdenv.isDarwin then "/Users/${config.home.user}"
					else "/home/${config.home.user}";
			};

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

			gtk = mkOption {
				type = attrs;
				default = {};
				description = "Home-manager provided gtk settings";
			};

			wayland = mkOption {
				type = attrs;
				default = {};
				description = "Home-manager provided wayland settings";
			};

			lib = mkOption {
				type = attrs;
				default = {};
				description = "Home-manager provided libs";
			};
		};
	};

	config = let
		user = config.home.user;
	in {
		programs.zsh.enable = true;
		users.users.${user} = {
			name = user;
			home = config.home.path;
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
				gtk = mkAliasDefinitions options.home.gtk;
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

		home.lib = config.home-manager.users.${config.home.user}.lib;
	};
}
