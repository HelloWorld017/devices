{ inputs, pkgs, lib, config, options, ... }: let
  inherit (lib) genAttrs;
  passThruAttrs = ["fonts" "gtk" "programs" "qt" "services" "wayland"];
  aliasAttrs = passThruAttrs ++ ["file" "configFile" "defaultApplications" "lib"];
in {
  options = let 
    inherit (lib) mkOption types;
    inherit (types) attrs listOf package str;
  in {
    home = {
      description = mkOption {
        type = str;
        default = "nenw*";
        description = "User description";
      };

      path = mkOption {
        type = str;
        default = if pkgs.stdenv.isDarwin then "/Users/${config.constants.user}"
          else "/home/${config.constants.user}";
      };

      packages = mkOption {
        type = listOf package;
        default = [];
        description = "Home-manager provided packages";
      };
    }
    // genAttrs aliasAttrs (_: mkOption {
      type = attrs;
      default = {};
    });
  };

  config = let
    alias = key: lib.mkAliasDefinitions options.home.${key};
    user = config.constants.user;
  in {
    programs.zsh.enable = true;
    users.groups.${user} = {};
    users.users.${user} = {
      name = user;
      home = config.home.path;
      shell = pkgs.zsh;
      extraGroups = [ user ];
      isNormalUser = true;
      description = config.home.description;
      openssh.authorizedKeys.keys =
        (import "${inputs.self}/keys.nix").all;
    };

    # Initialize Home
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${user} = {
        home = {
          file = alias "file";
          packages = alias "packages";
          stateVersion = "22.05";
        };
        xdg = {
          mimeApps = {
            enable = false;
            defaultApplications = alias "defaultApplications";
          };
          configFile = alias "configFile";
        };
      }
      // genAttrs passThruAttrs alias;
    };

    home.lib = config.home-manager.users.${user}.lib;
  };
}
